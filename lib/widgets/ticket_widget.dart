import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/deal.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/widgets/ticket_details.dart';
import 'package:kitchen_display_system/widgets/ticket_footer.dart';
import 'package:kitchen_display_system/widgets/ticket_header.dart';
import 'package:kitchen_display_system/widgets/ticket_sub_header.dart';

class TicketWidget extends StatelessWidget {
  final String selectedDepartment;
  final Order order;
  final void Function(String orderNumber) onDonePressed;
  final void Function(String orderNumber) onPreparingPressed;
  const TicketWidget({
    super.key,
    required this.selectedDepartment,
    required this.order,
    required this.onDonePressed,
    required this.onPreparingPressed,
  });

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 2.0);
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TicketHeader(order: order),
            divider,
            TicketSubHeader(order: order),
            Divider(color: primaryColor),
            RegularItemsTicketDetail(
              deals: _getDealsByDepartment(selectedDepartment, order.deals),
              items: _getItemsByDepartment(selectedDepartment, order.items),
            ),
            if (order.lessItems.isNotEmpty) Divider(color: primaryColor),
            if (order.lessItems.isNotEmpty)
              LessItemTicketDetails(
                lessItems:
                    _getItemsByDepartment(selectedDepartment, order.lessItems),
                lessDeals:
                    _getDealsByDepartment(selectedDepartment, order.lessDeals),
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
    );
  }

  List<Item> _getItemsByDepartment(String department, List<Item> items) {
    if (department == 'ALL') return items;
    return items.where((item) => item.department == department).toList();
  }

  List<Deal> _getDealsByDepartment(String department, List<Deal> deals) {
    if (department == 'ALL') return deals;
    return deals.where((deal) => deal.department == department).toList();
  }
}
