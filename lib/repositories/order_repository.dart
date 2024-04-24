import 'package:dio/dio.dart';
import 'package:kitchen_display_system/models/order.dart';

class OrdersRepository {
  late final Dio _dio;
  OrdersRepository(String serverIp) {
    _dio = Dio(BaseOptions(baseUrl: 'http://$serverIp/api'));
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
    //
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

  Future<void> updateOrder(String orderNumber, String status) async {
    final response = await _dio.get('/OrderStatus/$orderNumber/$status');
    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    }
  }
}
