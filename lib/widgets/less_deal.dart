import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/deal.dart';
import 'package:kitchen_display_system/widgets/dashed_divider.dart';

class LessDeal extends StatelessWidget {
  final Deal deal;
  const LessDeal({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                deal.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              deal.quantity.toString(),
              style: const TextStyle(
                color: Colors.red,
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Text(
                '     ${dealitem.quantity.toString()}',
                style: const TextStyle(
                  color: Colors.red,
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
