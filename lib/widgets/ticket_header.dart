import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';

class TicketHeader extends StatelessWidget {
  final Order order;
  const TicketHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${order.orderType.name.toUpperCase()} (${order.duration.inMinutes % 60}:${order.duration.inSeconds % 60})',
          style: textStyle,
        ),
        Text(order.number, style: textStyle.copyWith(fontSize: 20)),
      ],
    );
  }
}
