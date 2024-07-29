import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';

class CustomerTicket extends StatelessWidget {
  final Order order;
  const CustomerTicket({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            'ORDER#: ${order.number}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}
