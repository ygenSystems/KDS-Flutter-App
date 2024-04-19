import 'package:intl/intl.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/models/order_types.dart';

class Order {
  final String id;
  final String number;
  final OrderType orderType;
  final DateTime orderTime;
  final String waiter;
  final String tableNumber;
  final OrderStatus status;
  final List<Item> items;
  final List<Item> lessItems;
  Duration get duration => DateTime.now().difference(orderTime);

  Order({
    required this.id,
    required this.number,
    required this.orderType,
    required this.orderTime,
    required this.waiter,
    required this.tableNumber,
    required this.status,
    required this.items,
    required this.lessItems,
  });

  Order.fromMap({required Map<String, dynamic> map})
      : id = map['id'],
        number = map['number'].toString(),
        orderType = OrderType.values.firstWhere((e) => e.toString() == 'OrderType.${map['orderType']}'),
        orderTime = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['time']),
        waiter = map['waiter'],
        tableNumber = map['table'],
        status = OrderStatus.values.firstWhere((e) => e.toString() == 'OrderStatus.${map['kdsStatus']}'),
        items = (map['items'] as List<dynamic>).map((e) => Item.fromMap(e)).toList(),
        lessItems = (map['lessItems'] as List<dynamic>).map((e) => Item.fromMap(e)).toList();

  Order.empty()
      : this(
          id: '',
          number: '',
          orderType: OrderType.dineIn,
          orderTime: DateTime.now(),
          waiter: '',
          tableNumber: '',
          status: OrderStatus.preparing,
          items: [],
          lessItems: [],
        );
}
