import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_types.dart';

class TicketSubHeader extends StatelessWidget {
  final Order order;
  const TicketSubHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Theme.of(context).primaryColor);
    final now = DateTime.now();
    final difference = now.difference(order.orderTime).inMinutes;
    if (difference >= 15) {
      textStyle = textStyle.copyWith(color: Colors.black);
    } else if (difference >= 20) {
      textStyle = textStyle.copyWith(color: Colors.white);
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (order.orderType == OrderType.dineIn)
              LimitedBox(
                maxWidth: 50,
                child: Text(
                  'Tbl: ${order.tableNumber}'.toUpperCase(),
                  style: textStyle,
                ),
              )
            else
              const Text('- - - - - - - -'),
            LimitedBox(
              maxWidth: 150,
              child: Text(
                'Wtr: ${order.waiter}'.toUpperCase(),
                style: textStyle.copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time: ${DateFormat('hh:mm a').format(order.orderTime)}'
                  .toUpperCase(),
              style: textStyle,
            ),
            const Text(''),
          ],
        ),
      ],
    );
  }
}
