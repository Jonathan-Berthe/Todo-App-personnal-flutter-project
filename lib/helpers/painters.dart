import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class TitleCardPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final int factor;
  TitleCardPainter({
    @required this.primaryColor,
    @required this.secondaryColor,
    this.factor = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {

    var gradient = ui.Gradient.linear(
     
       Offset(0, 0), // near the top right
      Offset(size.width, size.height), 
       [
        primaryColor, 
        secondaryColor, 
      ]
    );
 
    final paint = Paint() // Le "pinceau"
    //..shader = gradient;
      ..color = secondaryColor;
    //..style = PaintingStyle.stroke;

    final Path path = Path(); // Le "tracé"

    path.moveTo(size.width / factor, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - (size.width / factor), size.height);
    path.lineTo(0, size.height);
    path.close();
    //path.lineTo(size.width / factor, 0);

    canvas.drawPath(path, paint); // draw rectangle on canvas
  }

  @override
  //Flutter calls this method whenever it needs to re-render CustomPainter. It gives you one parameter, which is the old instance of CustomPainter.
  // Ideally, you’d compare the old instance properties to the current ones and, if they’re equivalent, return false to not repaint. Otherwise, return true to repaint. So here, you compare the current color to the color of the oldDelegate.
  bool shouldRepaint(TitleCardPainter oldDelegate) {
    return true; // color != oldDelegate.color;
  }
}
