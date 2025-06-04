import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/widgets/dashed_divider.dart';

class LessItem extends StatelessWidget {
  final Item item;
  const LessItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                item.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              item.quantity.toString(),
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        if (item.comment.isNotEmpty)
          Row(
            children: [
              Text(
                '- ${item.comment}',
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
