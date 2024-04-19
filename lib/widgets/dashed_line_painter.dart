import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedLinePainter({this.color = Colors.grey, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double dashLength = strokeWidth * 1; // Adjust dash length as needed
    double spaceLength = gap * strokeWidth; // Adjust space length as needed

    for (double x = 0; x < size.width; x += dashLength + spaceLength) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashLength, 0), dashedPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
