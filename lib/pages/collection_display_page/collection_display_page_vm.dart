import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class CollectionDisplayPageVM {
  late final OrdersRepository _repo;
  CollectionDisplayPageVM() {
    _repo = Get.find<OrdersRepository>();
  }

  List<Order> orders = [];

  Future<List<Order>> getOrders() async {
    try {
      return orders = await _repo.getCDSOrders();
    } catch (e) {
      return orders;
    }
  }

  Stream<bool> getOrdersStream() async* {
    await for (var event in _repo.setupCDSSocket()) {
      if (event) yield true;
    }
  }

  void dispose() {
    _repo.dispose();
  }
}
