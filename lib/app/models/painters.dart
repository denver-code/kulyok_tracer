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

class ConnectionLine extends StatelessWidget {
  final NetworkNode fromNode;
  final NetworkNode toNode;

  const ConnectionLine({
    required this.fromNode,
    required this.toNode,
  });

  Offset _getNodeCenter(NetworkNode node) {
    // Node width is 75 and height is 75 from NodeWidget
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
        painter: OrthogonalLinePainter(
          from: fromCenter,
          to: toCenter,
        ),
        child: Container(),
      ),
    );
  }
}

class OrthogonalLinePainter extends CustomPainter {
  final Offset from;
  final Offset to;

  OrthogonalLinePainter({required this.from, required this.to});

  List<Offset> _calculateOrthogonalPath() {
    final points = <Offset>[];
    points.add(from);

    // Calculate the middle point for the orthogonal path
    final dx = (to.dx - from.dx).abs();
    final dy = (to.dy - from.dy).abs();

    // Decide whether to go horizontal first or vertical first based on the longer distance
    if (dx > dy) {
      // Go horizontal first
      points.add(Offset(to.dx, from.dy));
    } else {
      // Go vertical first
      points.add(Offset(from.dx, to.dy));
    }

    points.add(to);
    return points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Get the path points
    final points = _calculateOrthogonalPath();

    // Draw the path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Changed to true since we want to repaint when points change
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
