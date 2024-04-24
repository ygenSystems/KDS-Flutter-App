import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class KitchenDisplayPageVM {
  late final OrdersRepository _ordersRepository;
  KitchenDisplayPageVM(OrdersRepository ordersRepository) {
    _ordersRepository = ordersRepository;
  }

  List<Order> orders = [];

  bool _getRequested = false;
  Future<List<Order>> getOrders() async {
    try {
      if (_getRequested) return orders;
      _getRequested = true;
      return orders = await _ordersRepository.getKDSOrders();
    } catch (e) {
      return orders;
    } finally {
      _getRequested = false;
    }
  }

  bool _updateRequested = false;
  Future<void> updateOrder(String orderNumber, String s) async {
    try {
      if (_updateRequested) return;
      _updateRequested = true;
      await _ordersRepository.updateOrder(orderNumber, s);
    } catch (e) {
      print(e);
    } finally {
      _updateRequested = false;
    }
  }
}
