import 'package:dreampainter/models/drawing_data.dart';
import 'package:dreampainter/screens/custom_coloring_screen.dart';
import 'package:dreampainter/screens/drawing_list_screen.dart';
import 'package:dreampainter/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickAndNavigate(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomColoringScreen(imagePath: imageFile.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artistry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return CategoryCard(
                title: 'From Gallery',
                icon: Icons.add_photo_alternate_outlined,
                onTap: () => _pickAndNavigate(context),
              );
            }
            final category = categories[index];
            return CategoryCard(
              title: category.name,
              icon: category.icon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DrawingListScreen(category: category)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}