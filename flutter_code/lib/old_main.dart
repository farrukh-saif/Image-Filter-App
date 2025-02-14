import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:before_after/before_after.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImagePickerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  var value = 0.5;

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String? newPath = await _copyToAppStorage(pickedFile.path);
      if (newPath != null) {
        setState(() {
          _image = File(newPath);
        });
      }
    }
  }

  // Copy the image to app storage
  Future<String?> _copyToAppStorage(String originalPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = path.join(directory.path, 'selected_image.jpg');

      final File newFile = await File(originalPath).copy(newPath);
      return newFile.path;
    } catch (e) {
      print("Error copying image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Filter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? BeforeAfter(
                    value: value,
                    before: Image.file(_image!, height: 300),
                    after: Image.file(_image!, height: 300),
                    onValueChanged: (value) {
                      setState(() => this.value = value);
                    },
                    thumbColor: Colors.black,
                    trackColor: Colors.black38,
                  )
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              onPressed: _pickImage,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    const Text("Pick Image"),
                    const SizedBox(height: 5),
                    Icon(IconData(0xf29e, fontFamily: 'MaterialIcons'))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}