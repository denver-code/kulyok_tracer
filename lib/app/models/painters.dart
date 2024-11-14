import 'package:flutter/material.dart';
import 'package:kulyok/app/models/network_nodes.dart';

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

class SmoothConnectionPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final double cornerRadius;

  SmoothConnectionPainter({
    required this.from,
    required this.to,
    this.cornerRadius = 6.0,
  });

  void _drawEndpoint(Canvas canvas, Offset position, Paint linePaint,
      {bool isStart = false}) {
    // Draw interface connector
    final rect = Rect.fromCenter(
      center: position,
      width: 16,
      height: 8,
    );

    // Use the same paint as the line for consistent appearance
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1)),
      linePaint,
    );

    // Draw the connection status dot for the start point
    if (isStart) {
      canvas.drawCircle(
        position,
        2.0,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 78, 78, 78)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw the connection line
    final path = Path();
    path.moveTo(from.dx, from.dy);

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final shouldGoVerticalFirst = dx.abs() < dy.abs();

    if (shouldGoVerticalFirst) {
      if (dy.abs() > cornerRadius * 2) {
        path.lineTo(from.dx, to.dy - (dy > 0 ? cornerRadius : -cornerRadius));
        path.quadraticBezierTo(
          from.dx,
          to.dy,
          from.dx + (dx > 0 ? cornerRadius : -cornerRadius),
          to.dy,
        );
      } else {
        path.lineTo(from.dx, to.dy);
      }
      path.lineTo(to.dx, to.dy);
    } else {
      if (dx.abs() > cornerRadius * 2) {
        path.lineTo(to.dx - (dx > 0 ? cornerRadius : -cornerRadius), from.dy);
        path.quadraticBezierTo(
          to.dx,
          from.dy,
          to.dx,
          from.dy + (dy > 0 ? cornerRadius : -cornerRadius),
        );
      } else {
        path.lineTo(to.dx, from.dy);
      }
      path.lineTo(to.dx, to.dy);
    }

    // Draw the main connection line
    canvas.drawPath(path, paint);

    // Draw both endpoints with connector boxes
    _drawEndpoint(canvas, from, paint,
        isStart: true); // Start point with green dot
    _drawEndpoint(canvas, to, paint); // End point
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConnectionLine extends StatelessWidget {
  final NetworkNode fromNode;
  final NetworkNode toNode;

  const ConnectionLine({
    super.key,
    required this.fromNode,
    required this.toNode,
  });

  Offset _getNodeCenter(NetworkNode node) {
    const nodeSize = 75.0;
    return Offset(
      node.position.dx + nodeSize / 2,
      node.position.dy + nodeSize / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromCenter = _getNodeCenter(fromNode);
    final toCenter = _getNodeCenter(toNode);

    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        painter: SmoothConnectionPainter(
          from: fromCenter,
          to: toCenter,
          cornerRadius: 6.0,
        ),
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
