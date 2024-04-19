import 'item_status.dart';

class Item {
  final String id;
  final String name;
  final String quantity;
  final String comment;
  final ItemStatus status;
  final bool isNew;

  Item.empty()
      : id = '',
        name = '',
        quantity = '',
        comment = '',
        status = ItemStatus.pending,
        isNew = true;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.comment,
    required this.status,
    required this.isNew,
  });

  Item.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),
        name = map['name'],
        quantity = map['quantity'].toString(),
        comment = map['comment'],
        status = ItemStatus.pending,
        isNew = map['isNew'] ?? true;
}
