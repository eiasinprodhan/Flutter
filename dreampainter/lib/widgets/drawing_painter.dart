import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<Path> paths;
  final List<Color> colors;

  DrawingPainter({required this.paths, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    final Rect totalBounds = paths.fold(
      Rect.zero,
          (prev, path) => prev.isEmpty ? path.getBounds() : prev.expandToInclude(path.getBounds()),
    );

    if (totalBounds.isEmpty) return;

    final double scaleX = size.width / totalBounds.width;
    final double scaleY = size.height / totalBounds.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-totalBounds.center.dx, -totalBounds.center.dy);

    for (int i = 0; i < paths.length; i++) {
      final fillPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5 / scale
        ..style = PaintingStyle.stroke;

      canvas.drawPath(paths[i], fillPaint);
      canvas.drawPath(paths[i], strokePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}