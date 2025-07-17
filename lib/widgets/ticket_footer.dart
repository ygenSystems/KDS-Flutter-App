import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';

class TicketFooter extends StatelessWidget {
  final Order order;
  final void Function() onDonePressed;
  final void Function() onPreparingPressed;
  const TicketFooter({
    super.key,
    required this.order,
    required this.onDonePressed,
    required this.onPreparingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final OrderStatus status = order.status;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPreparingPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color:
                    status == OrderStatus.preparing
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                        : null,
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'PREPARING',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: InkWell(
            onTap: onDonePressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'DONE',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
