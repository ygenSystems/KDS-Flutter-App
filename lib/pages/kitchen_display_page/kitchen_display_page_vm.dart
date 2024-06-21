import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class KitchenDisplayController {
  late final OrdersRepository _repo;
  KitchenDisplayController() {
    _repo = Get.find<OrdersRepository>();
  }

  List<Order> orders = [];

  Future<List<Order>> getOrders() async {
    try {
      return orders = await _repo.getKDSOrders();
    } catch (e) {
      return orders;
    }
  }

  void updateOrder(String orderNumber, String status) {
    _repo.updateOrderWSocket(orderNumber, status);
  }

  Stream<bool> getOrderStream() async* {
    await for (var event in _repo.setupKDSSocket()) {
      if (event) {
        yield event;
      }
    }
  }

  void dispose() {
    _repo.dispose();
  }
}
