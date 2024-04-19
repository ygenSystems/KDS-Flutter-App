import 'package:flutter/material.dart';
import 'package:kitchen_display_system/widgets/dashed_line_painter.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return CustomPaint(
      painter: DashedLinePainter(color: primaryColor),
      size: const Size(double.infinity, 1.0),
    );
  }
}
