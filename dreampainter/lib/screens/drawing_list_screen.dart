import 'package:dreampainter/screens/svg_coloring_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dreampainter/models/drawing_data.dart';
import 'package:dreampainter/constants/app_colors.dart';

class DrawingListScreen extends StatelessWidget {
  final DrawingCategory category;
  const DrawingListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: category.drawings.length,
        itemBuilder: (context, index) {
          final drawingAsset = category.drawings[index];
          return Card(
            elevation: 4.0,
            shadowColor: AppColors.primary.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SvgColoringScreen(svgAssetPath: drawingAsset)),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  drawingAsset,
                  placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}