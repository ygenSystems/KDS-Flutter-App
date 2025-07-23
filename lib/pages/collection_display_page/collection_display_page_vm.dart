import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class CollectionDisplayPageVM {
  late final OrdersRepository _repo;
  CollectionDisplayPageVM() {
    _repo = Get.find<OrdersRepository>();
  }

  List<Order> orders = [];

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
