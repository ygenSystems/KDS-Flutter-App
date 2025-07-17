import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';

class TicketHeader extends StatelessWidget {
  final Order order;
  const TicketHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    final now = DateTime.now();
    final difference = now.difference(order.orderTime).inMinutes;
    if (difference >= 15) {
      textStyle = textStyle.copyWith(color: Colors.black);
    } else if (difference >= 20) {
      textStyle = textStyle.copyWith(color: Colors.white);
    }

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
