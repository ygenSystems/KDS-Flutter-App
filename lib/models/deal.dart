import 'dart:collection';

import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/models/item_status.dart';

class Deal extends Item {
  final List<DealItem> dealItems;
  Deal({
    required String id,
    required String name,
    required String department,
    required String comment,
    required bool isNew,
    required String quantity,
    required ItemStatus status,
    required this.dealItems,
  }) : super(id: id, department: department, name: name, comment: comment, isNew: isNew, quantity: quantity, status: status);
  Deal.fromMap(super.map)
      : dealItems = (map['dealItems'] as List<dynamic>).map((e) => DealItem.fromMap(e)).toList(),
        super.fromMap();
}

class DealItem {
  final String name;
  final int quantity;
  final String department;

  DealItem.empty()
      : name = '',
        quantity = 0,
        department = '';

  DealItem.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        quantity = map['quantity'],
        department = map['department'];
}
