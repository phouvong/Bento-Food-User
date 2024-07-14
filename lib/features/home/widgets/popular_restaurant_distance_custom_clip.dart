import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RestaurantDistanceCustomClip extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(4.8852, 4.72085);
    path_0.cubicTo(5.47706, 2.24581, 7.68956, 0.5, 10.2344, 0.5);
    path_0.lineTo(51.8644, 0.5);
    path_0.cubicTo(54.3673, 0.5, 56.5545, 2.18986, 57.1863, 4.61168);
    path_0.lineTo(61.8528, 22.5);
    path_0.lineTo(0.633662, 22.5);
    path_0.lineTo(4.8852, 4.72085);
    path_0.close();

    Paint paint0Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint0Stroke.shader = ui.Gradient.linear(Offset(size.width * 0.4960317, size.height * -8.802609e-8),
        Offset(size.width * 0.5000000, size.height * 1.086957), [const Color(0xffD7D7D7).withOpacity(1), Colors.white.withOpacity(0)], [0, 1]);
    canvas.drawPath(path_0, paint0Stroke);

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
