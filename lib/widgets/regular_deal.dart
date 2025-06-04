import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:kitchen_display_system/models/deal.dart';
import 'package:kitchen_display_system/widgets/dashed_divider.dart';

class RegularDeal extends StatelessWidget {
  final Deal deal;
  const RegularDeal({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                deal.name.toUpperCase(),
                style: TextStyle(
                  color: deal.isNew
                      ? Colors.green
                      : deal.hexColor == null
                          ? primaryColor
                          : HexColor(deal.hexColor!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              deal.quantity.toString(),
              style: TextStyle(
                color: deal.isNew
                    ? Colors.green
                    : deal.hexColor == null
                        ? primaryColor
                        : HexColor(deal.hexColor!),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        ...List.generate(deal.dealItems.length, (index) {
          final dealitem = deal.dealItems[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '   ${dealitem.name.toUpperCase()}',
                  style: TextStyle(
                    color: deal.isNew ? Colors.green : primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Text(
                '     ${dealitem.quantity.toString()}',
                style: TextStyle(
                  color: deal.isNew
                      ? Colors.red
                      : deal.isNew
                          ? Colors.green
                          : primaryColor,
                ),
              ),
            ],
          );
        }),
        if (deal.comment.isNotEmpty)
          Row(
            children: [
              Text(
                '- ${deal.comment}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        const DashedDivider(),
      ],
    );
  }
}
