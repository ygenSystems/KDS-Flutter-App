import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/deal.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/widgets/less_deal.dart';
import 'package:kitchen_display_system/widgets/less_item.dart';
import 'package:kitchen_display_system/widgets/regular_deal.dart';
import 'package:kitchen_display_system/widgets/regular_item.dart';

class RegularItemsTicketDetail extends StatelessWidget {
  final String title = 'REGULAR ITEMS';
  final List<Item> items;
  final List<Deal> deals;
  const RegularItemsTicketDetail({
    super.key,
    required this.items,
    required this.deals,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(color: primaryColor),
          ],
        ),
        ...List.generate(items.length, (index) {
          final item = items[index];
          return RegularItem(item: item);
        }),
        if (items.isNotEmpty && deals.isNotEmpty) const SizedBox(height: 8.0),
        ...List.generate(deals.length, (index) {
          final deal = deals[index];
          return RegularDeal(deal: deal);
        }),
      ],
    );
  }
}

class LessItemTicketDetails extends StatelessWidget {
  final String title = 'LESS ITEMS';
  final List<Item> lessItems;
  final List<Deal> lessDeals;
  const LessItemTicketDetails({
    super.key,
    required this.lessItems,
    required this.lessDeals,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(color: primaryColor),
          ],
        ),
        if (lessDeals.isNotEmpty && lessItems.isNotEmpty)
          const SizedBox(height: 8.0),
        ...List.generate(lessItems.length, (index) {
          final item = lessItems[index];
          return LessItem(item: item);
        }),
        if (lessItems.isNotEmpty && lessDeals.isNotEmpty)
          const SizedBox(height: 8.0),
        ...List.generate(lessDeals.length, (index) {
          final deal = lessDeals[index];
          return LessDeal(deal: deal);
        }),
      ],
    );
  }
}
