import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dreampainter/utils/svg_parser.dart';
import 'package:dreampainter/widgets/color_palette.dart';
import 'package:dreampainter/widgets/drawing_painter.dart';

class SvgColoringScreen extends StatefulWidget {
  final String svgAssetPath;
  const SvgColoringScreen({super.key, required this.svgAssetPath});

  @override
  State<SvgColoringScreen> createState() => _SvgColoringScreenState();
}

class _SvgColoringScreenState extends State<SvgColoringScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final SvgParser _parser = SvgParser();
  List<Path> _paths = [];
  late List<Color> _pathColors;
  Color _selectedColor = Colors.red;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final parsedPaths = await _parser.parseSvgFromAsset(widget.svgAssetPath);
    setState(() {
      _paths = parsedPaths;
      _pathColors = List<Color>.filled(_paths.length, Colors.white);
      _isLoading = false;
    });
  }

  void _clearCanvas() {
    setState(() {
      _pathColors = List<Color>.filled(_paths.length, Colors.white);
    });
  }

  Future<void> _saveImage() async {
    final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image != null) {
      final result = await ImageGallerySaver.saveImage(image, name: "Artistry_SVG_${DateTime.now().toIso8601String()}");
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
        title: const Text('Color It'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _clearCanvas, tooltip: 'Clear'),
          IconButton(icon: const Icon(Icons.save_alt), onPressed: _saveImage, tooltip: 'Save'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: GestureDetector(
                      onTapDown: (details) {
                        final tapPosition = details.localPosition;
                        for (int i = _paths.length - 1; i >= 0; i--) {
                          if (_paths[i].contains(tapPosition)) {
                            setState(() => _pathColors[i] = _selectedColor);
                            break;
                          }
                        }
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(paths: _paths, colors: _pathColors),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ColorPalette(
            selectedColor: _selectedColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
          ),
        ],
      ),
    );
  }
}