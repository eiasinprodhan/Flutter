import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(const MaterialApp(home: SvgColoringScreen(svgAssetPath: 'assets/cat.svg')));
}

class SvgColoringScreen extends StatefulWidget {
  final String svgAssetPath;
  const SvgColoringScreen({Key? key, required this.svgAssetPath}) : super(key: key);

  @override
  State<SvgColoringScreen> createState() => _SvgColoringScreenState();
}

class _SvgColoringScreenState extends State<SvgColoringScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // We fake path regions here; ideally, parse SVG and create Paths.
  // For demo, assume three rectangular areas we can tap to color.
  final List<Rect> tappableRegions = [
    Rect.fromLTWH(20, 20, 100, 100),  // Example rectangle 1
    Rect.fromLTWH(150, 50, 100, 100), // Example rectangle 2
    Rect.fromLTWH(80, 160, 100, 100), // Example rectangle 3
  ];

  List<Color> pathColors = [];
  Color selectedColor = Colors.red;

  @override
  void initState() {
    super.initState();
    pathColors = List<Color>.filled(tappableRegions.length, Colors.white);
  }

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final tapPos = details.localPosition;

    // Map tapPos to SVG coordinate system assuming SVG viewBox 0 0 300 300 for example
    // Adjust based on your SVG's actual viewBox and widget size.
    final scaleX = 300 / constraints.maxWidth;
    final scaleY = 300 / constraints.maxHeight;

    final svgTapX = tapPos.dx * scaleX;
    final svgTapY = tapPos.dy * scaleY;

    for (int i = 0; i < tappableRegions.length; i++) {
      if (tappableRegions[i].contains(Offset(svgTapX, svgTapY))) {
        setState(() {
          pathColors[i] = selectedColor;
        });
        break;
      }
    }
  }

  Future<void> _saveImage() async {
    final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image != null) {
      final result = await ImageGallerySaver.saveImage(
          image,
          name: "Colored_SVG_${DateTime.now().toIso8601String()}");
      if (mounted && result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Gallery!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Coloring Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save',
            onPressed: _saveImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Screenshot(
                controller: _screenshotController,
                child: LayoutBuilder(builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) => _handleTapDown(details, constraints),
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          widget.svgAssetPath,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.contain,
                        ),
                        // Custom paint colored rectangles to simulate colored regions
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _RegionsPainter(
                            regions: tappableRegions,
                            colors: pathColors,
                            svgSize: Size(300, 300),
                            widgetSize: Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
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
              child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
            ),
          );
        },
      ),
    );
  }
}

class _RegionsPainter extends CustomPainter {
  final List<Rect> regions;
  final List<Color> colors;
  final Size svgSize; // e.g., SVG viewBox size (300x300)
  final Size widgetSize; // widget size where SVG is painted

  _RegionsPainter({
    required this.regions,
    required this.colors,
    required this.svgSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale factors
    final scaleX = widgetSize.width / svgSize.width;
    final scaleY = widgetSize.height / svgSize.height;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < regions.length; i++) {
      paint.color = colors[i].withOpacity(0.6);
      final r = regions[i];
      final rect = Rect.fromLTWH(r.left * scaleX, r.top * scaleY, r.width * scaleX, r.height * scaleY);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RegionsPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
