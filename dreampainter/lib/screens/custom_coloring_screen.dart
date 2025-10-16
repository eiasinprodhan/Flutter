import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dreampainter/utils/flood_fill.dart';
import 'package:dreampainter/widgets/color_palette.dart';

class CustomColoringScreen extends StatefulWidget {
  final String imagePath;
  const CustomColoringScreen({super.key, required this.imagePath});

  @override
  State<CustomColoringScreen> createState() => _CustomColoringScreenState();
}

class _CustomColoringScreenState extends State<CustomColoringScreen> {
  img.Image? _editableImage;
  Uint8List? _displayImageBytes;
  Color _selectedColor = Colors.red;
  bool _isProcessing = true;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final fileBytes = await File(widget.imagePath).readAsBytes();
    final decodedImage = img.decodeImage(fileBytes);
    if (decodedImage != null) {
      setState(() {
        _editableImage = decodedImage;
        _displayImageBytes = Uint8List.fromList(img.encodePng(decodedImage));
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleFill(Offset tapPosition) async {
    if (_editableImage == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 20)); // Allow UI to show loader

    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final int startX = (tapPosition.dx * (_editableImage!.width / imageBox.size.width)).floor();
    final int startY = (tapPosition.dy * (_editableImage!.height / imageBox.size.height)).floor();

    final img.Image tempImage = _editableImage!.clone();
    final replacementColor = img.ColorRgba8(_selectedColor.red, _selectedColor.green, _selectedColor.blue, _selectedColor.alpha);

    // Run flood fill in a separate isolate to prevent UI freeze
    await Future(() => floodFill(tempImage, startX, startY, replacementColor));

    setState(() {
      _editableImage = tempImage;
      _displayImageBytes = Uint8List.fromList(img.encodePng(tempImage));
      _isProcessing = false;
    });
  }

  Future<void> _saveImage() async {
    if (_displayImageBytes == null) return;
    final result = await ImageGallerySaver.saveImage(_displayImageBytes!, name: "Artistry_Custom_${DateTime.now().toIso8601String()}");
    if (mounted && result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Gallery!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Your Photo'),
        actions: [
          IconButton(icon: const Icon(Icons.save_alt), onPressed: _saveImage, tooltip: 'Save'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_displayImageBytes != null)
                    GestureDetector(
                      onTapDown: (details) => _handleFill(details.localPosition),
                      child: Image.memory(
                        _displayImageBytes!,
                        key: _imageKey,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                ],
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