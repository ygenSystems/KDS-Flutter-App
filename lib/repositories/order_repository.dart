import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:signalr_netcore/signalr_client.dart';

class OrdersRepository {
  late final Dio _dio;
  late final HubConnection _hubConnection;
  final String _serverIp;
  late final Timer _timer;
  OrdersRepository() : _serverIp = GetStorage().read<String?>('server_ip')! {
    _dio = Dio(BaseOptions(baseUrl: 'http://$_serverIp/api/'));
  }

  Future<void> setupSignalR(
    ReconnectedCallback onReconnected,
    ReconnectingCallback onReconnecting,
  ) async {
    final address = _serverIp.split(':');
    _hubConnection =
        HubConnectionBuilder()
            .withUrl(
              'http://${address[0]}:${address[1]}/notificationhub',
              options: HttpConnectionOptions(
                transport: HttpTransportType.WebSockets,
              ),
            )
            .withAutomaticReconnect()
            .build();
    await _hubConnection.start();
    _hubConnection.onreconnected(onReconnected);
    _hubConnection.onreconnecting(onReconnecting);
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_hubConnection.state == HubConnectionState.Disconnected) {
        try {
          await _hubConnection.start();
        } catch (e) {
          print('Error reconnecting: $e');
        }
      }
    });
  }

  void setKDSOrderOnReceive(void Function(Order) onNewOrder) {
    _hubConnection.on('NewKDSOrder', (args) {
      if (args != null && args[0] != null) {
        final map = args[0] as Map<String, dynamic>;
        final order = Order.fromMap(map: map);
        onNewOrder(order);
      }
    });
  }

  void setCDSOrderOnReceive(void Function(Order) onNewOrder) {
    _hubConnection.on('NewCDSOrder', (args) {
      if (args != null && args[0] != null) {
        final map = args[0] as Map<String, dynamic>;
        final order = Order.fromMap(map: map);
        onNewOrder(order);
      }
    });
  }

  Future<void> getKDSOrders(String department) async {
    await _hubConnection.send('GetKDSOrders', args: [department]);
  }

  Future<void> getCDSOrders() async {
    await _hubConnection.send('GetCDSOrders');
  }

  Future<bool> updateOrder(String orderId, String status) async {
    if (_hubConnection.state != HubConnectionState.Connected) {
      return false;
    }
    if (status == 'done') {
      await _hubConnection.send('SetDone', args: [orderId]);
      return true;
    } else if (status == 'preparing') {
      await _hubConnection.send('SetPreparing', args: [orderId]);
      return true;
    }
    return false;
  }

  Future<List<Department>> getDepartments() async {
    final response = await _dio.get('/KDSDepartments');
    if (response.statusCode != 200) {
      throw Exception('Failed to load orders');
    }
    final List<dynamic> list = response.data;
    if (list.isEmpty) {
      return [];
    }
    return list.map((e) {
      return Department.fromMap(map: e);
    }).toList();
  }

  void dispose() {
    _hubConnection.stop();
    _timer.cancel();
  }
}
