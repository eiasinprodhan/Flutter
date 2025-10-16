import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: SvgColoringDemo()));
}

class SvgColoringDemo extends StatefulWidget {
  const SvgColoringDemo({Key? key}) : super(key: key);

  @override
  State<SvgColoringDemo> createState() => _SvgColoringDemoState();
}

class _SvgColoringDemoState extends State<SvgColoringDemo> {
  // Example paths (replace with your actual SVG paths)
  final List<Path> paths = [
    Path()..addOval(Rect.fromCircle(center: Offset(0, 0), radius: 50)),
    Path()
      ..moveTo(60, 0)
      ..lineTo(110, 50)
      ..lineTo(60, 100)
      ..close(),
    Path()..addRect(Rect.fromLTWH(-70, -70, 40, 40)),
  ];

  late List<Color> pathColors;
  Color selectedColor = Colors.red;

  // We'll store the transform used in painter to invert it on tap
  Matrix4? _transformMatrix;

  @override
  void initState() {
    super.initState();
    pathColors = List<Color>.filled(paths.length, Colors.white);
  }

  void _onTapDown(TapDownDetails details, Size size) {
    if (_transformMatrix == null) return;

    // Invert the matrix to convert tap position to path coordinate space
    final inverseMatrix = Matrix4.inverted(_transformMatrix!);

    // Transform tap position from widget coordinate to path coordinate system
    final localPos = details.localPosition;
    final transformed = MatrixUtils.transformPoint(inverseMatrix, localPos);

    // Hit test all paths from top to bottom (last drawn first)
    for (int i = paths.length - 1; i >= 0; i--) {
      if (paths[i].contains(transformed)) {
        setState(() {
          pathColors[i] = selectedColor;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SVG Coloring Demo"),
        actions: [
          IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear colors',
              onPressed: () {
                setState(() {
                  pathColors = List<Color>.filled(paths.length, Colors.white);
                });
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);

              return GestureDetector(
                onTapDown: (details) => _onTapDown(details, size),
                child: CustomPaint(
                  size: size,
                  painter: DrawingPainterWithTransform(
                    paths: paths,
                    colors: pathColors,
                    onTransformUpdate: (matrix) {
                      _transformMatrix = matrix;
                    },
                  ),
                ),
              );
            }),
          ),
          _buildColorSelector(),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.black,
      Colors.grey,
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color == selectedColor;
          return GestureDetector(
            onTap: () => setState(() => selectedColor = color),
            child: CircleAvatar(
              backgroundColor: color,
              radius: isSelected ? 22 : 18,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// Your DrawingPainter but modified to report transform matrix used
class DrawingPainterWithTransform extends CustomPainter {
  final List<Path> paths;
  final List<Color> colors;
  final ValueChanged<Matrix4> onTransformUpdate;

  DrawingPainterWithTransform({
    required this.paths,
    required this.colors,
    required this.onTransformUpdate,
  });

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

    // Calculate transform matrix for painting
    final Matrix4 transform = Matrix4.identity();
    transform.translate(size.width / 2, size.height / 2);
    transform.scale(scale);
    transform.translate(-totalBounds.center.dx, -totalBounds.center.dy);

    // Report matrix to caller
    onTransformUpdate(transform);

    canvas.save();
    canvas.transform(transform.storage);

    final paintFill = Paint()..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5 / scale
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < paths.length; i++) {
      paintFill.color = colors[i];
      canvas.drawPath(paths[i], paintFill);
      canvas.drawPath(paths[i], paintStroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainterWithTransform oldDelegate) {
    return oldDelegate.colors != colors || oldDelegate.paths != paths;
  }
}
