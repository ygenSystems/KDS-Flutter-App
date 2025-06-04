import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/widgets/dashed_divider.dart';

class RegularItem extends StatelessWidget {
  final Item item;
  const RegularItem({super.key, required this.item});

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
                item.name.toUpperCase(),
                style: TextStyle(
                  color: item.isNew
                      ? Colors.green
                      : item.hexColor == null
                          ? primaryColor
                          : HexColor(item.hexColor!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              item.quantity.toString(),
              style: TextStyle(
                color: item.isNew ? Colors.green : primaryColor,
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
