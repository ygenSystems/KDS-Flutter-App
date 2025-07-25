import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';
import 'package:signalr_netcore/signalr_client.dart';

class CollectionDisplayPageVM {
  late final OrdersRepository _repo;
  CollectionDisplayPageVM() {
    _repo = Get.find<OrdersRepository>();
  }

  Future<void> setupSignalR(
    ReconnectedCallback onReconnected,
    ReconnectingCallback onReconnecting,
  ) async {
    await _repo.setupSignalR(onReconnected, onReconnecting);
  }

  Future<void> getOrders() async {
    await _repo.getCDSOrders();
  }

  void getOrdersStream(void Function(Order order) onData) {
    _repo.setCDSOrderOnReceive(onData);
  }

  void dispose() {
    _repo.dispose();
  }
}
