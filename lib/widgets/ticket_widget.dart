import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/widgets/ticket_details.dart';
import 'package:kitchen_display_system/widgets/ticket_footer.dart';
import 'package:kitchen_display_system/widgets/ticket_header.dart';
import 'package:kitchen_display_system/widgets/ticket_sub_header.dart';

class TicketWidget extends StatelessWidget {
  final Order order;
  final void Function(String orderNumber) onDonePressed;
  final void Function(String orderNumber) onPreparingPressed;
  final Color? alternateColor;
  final Color? baseColor;
  const TicketWidget({
    super.key,
    required this.order,
    required this.onDonePressed,
    required this.onPreparingPressed,
    this.alternateColor,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 2.0);
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      color: alternateColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: primaryColor),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Builder(
              builder: (context) {
                var child = Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TicketHeader(order: order),
                      divider,
                      TicketSubHeader(order: order),
                    ],
                  ),
                );
                if (baseColor == null) {
                  return child;
                }
                return ColoredBox(color: baseColor!, child: child);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Divider(color: primaryColor),
                RegularItemsTicketDetail(
                  deals: order.deals,
                  items: order.items,
                ),
                if (order.lessItems.isNotEmpty) Divider(color: primaryColor),
                if (order.lessItems.isNotEmpty)
                  LessItemTicketDetails(
                    lessItems: order.lessItems,
                    lessDeals: order.lessDeals,
                  ),
                Divider(color: primaryColor),
                TicketFooter(
                  order: order,
                  onDonePressed: onDonePressed,
                  onPreparingPressed: onPreparingPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
