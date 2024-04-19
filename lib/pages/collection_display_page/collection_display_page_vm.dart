import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class CollectionDisplayPageVM {
  final _ordersRepository = OrdersRepository();

  List<Order> orders = [];

  bool _getRequested = false;
  Future<List<Order>> getOrders() async {
    try {
      if (_getRequested) return orders;
      _getRequested = true;
      return orders = await _ordersRepository.getCDSOrders();
    } catch (e) {
      _getRequested = false;
      return orders;
    }
  }
}
