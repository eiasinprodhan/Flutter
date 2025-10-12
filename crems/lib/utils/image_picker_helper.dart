import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';
import 'app_colors.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<PickedImageData?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          return PickedImageData(
            bytes: bytes,
            path: pickedFile.path,
            name: pickedFile.name,
          );
        } else {
          return PickedImageData(
            file: File(pickedFile.path),
            path: pickedFile.path,
            name: pickedFile.name,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    if (kIsWeb) {
      return ImageSource.gallery;
    }

    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class PickedImageData {
  final File? file;
  final Uint8List? bytes;
  final String path;
  final String name;

  PickedImageData({
    this.file,
    this.bytes,
    required this.path,
    required this.name,
  });

  bool get isWeb => bytes != null;
  bool get isMobile => file != null;
}