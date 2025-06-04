import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrdersRepository {
  late final Dio _dio;
  late final WebSocketChannel _socket;
  final String _serverIp;
  OrdersRepository() : _serverIp = GetStorage().read<String?>('server_ip')! {
    _dio = Dio(BaseOptions(baseUrl: 'http://$_serverIp/api/'));
  }

  Stream<bool> setupKDSSocket() async* {
    final address = _serverIp.split(':');
    final wsUrl = Uri(
      host: address[0],
      port: int.parse(address[1]),
      scheme: 'ws',
      path: 'ws/kds',
    );
    _socket = WebSocketChannel.connect(wsUrl);
    await _socket.ready;
    await for (var value in _socket.stream) {
      switch (value) {
        case 'GETORDERS':
          yield true;
          break;
        default:
          yield false;
          break;
      }
    }
  }

  Stream<bool> setupCDSSocket() async* {
    final address = _serverIp.split(':');
    final wsUrl = Uri(
      host: address[0],
      port: int.parse(address[1]),
      scheme: 'ws',
      path: 'ws/cds',
    );
    _socket = WebSocketChannel.connect(wsUrl);
    await for (var value in _socket.stream) {
      switch (value) {
        case 'GETORDERS':
          yield true;
          break;
        default:
          yield false;
          break;
      }
    }
  }

  Future<List<Order>> getKDSOrders() async {
    final response = await _dio.get('/KDSOrders');
    if (response.statusCode != 200) {
      throw Exception('Failed to load orders');
    }
    final List<dynamic> list = response.data;
    if (list.isEmpty) {
      return [];
    }
    return list.map((e) {
      return Order.fromMap(map: e);
    }).toList();
  }

  Future<List<Order>> getCDSOrders() async {
    final response = await _dio.get('/CDSOrders');
    if (response.statusCode != 200) {
      throw Exception('Failed to load orders');
    }
    final List<dynamic> list = response.data;
    if (list.isEmpty) {
      return [];
    }
    return list.map((e) {
      return Order.fromMap(map: e);
    }).toList();
  }

  bool updateOrderWSocket(String orderNumber, String status) {
    if (_socket.closeCode != null) return false;
    _socket.sink.add('ORDERSTATUS');
    _socket.sink.add(orderNumber);
    _socket.sink.add(status);
    return true;
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
    _socket.sink.close(1000);
  }
}
