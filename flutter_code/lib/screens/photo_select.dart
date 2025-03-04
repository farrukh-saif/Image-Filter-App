import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//Conditional import
import 'apply_effects_native.dart' if (dart.library.html) 'apply_effects_web.dart';


class PhotoSelectScreen extends StatelessWidget {
  const PhotoSelectScreen({
    super.key,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplyEffectsScreen(
              imageBytes: bytes,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212121),
      body: Center(
        child: GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: 170,
            height: 170,
            padding: const EdgeInsets.symmetric(
              horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Photo',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  Icons.photo_outlined,
                  size: 36,
                  color: const Color(0xFF212121),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}