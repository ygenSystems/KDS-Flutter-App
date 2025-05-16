import 'package:kitchen_display_system/models/item.dart';

class Deal extends Item {
  final List<DealItem> dealItems;
  Deal({
    required super.id,
    required super.name,
    required super.department,
    required super.comment,
    required super.isNew,
    required super.quantity,
    required super.status,
    required super.hexColor,
    required this.dealItems,
  });
  Deal.fromMap(super.map)
      : dealItems = (map['dealItems'] as List<dynamic>).map((e) => DealItem.fromMap(e)).toList(),
        super.fromMap();
}

class DealItem {
  final String name;
  final int quantity;
  final String? hexColor;
  final String department;

  DealItem.empty()
      : name = '',
        quantity = 0,
        department = '',
        hexColor = null;

  DealItem.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        quantity = map['quantity'],
        department = map['department'],
        hexColor = map['hexColor'];
}
