import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const double spacing = 20;
    const double dotSize = 2;

    // Calculate the number of dots needed
    int horizontalDots = (size.width / spacing).ceil();
    int verticalDots = (size.height / spacing).ceil();

    // Draw dots
    for (int i = 0; i <= horizontalDots; i++) {
      for (int j = 0; j <= verticalDots; j++) {
        canvas.drawCircle(
          Offset(i * spacing, j * spacing),
          dotSize / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ConnectionLine extends StatelessWidget {
  final Offset from;
  final Offset to;

  const ConnectionLine({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        painter: LinePainter(from: from, to: to),
        child: Container(),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset from;
  final Offset to;

  LinePainter({required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
