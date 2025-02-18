import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'screens/photo_select.dart';
import 'screens/apply_effects.dart';
import 'screens/final_result.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Editor',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToApplyEffects(BuildContext context, Uint8List imageBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyEffectsScreen(
          imageBytes: imageBytes,
          onBack: () => Navigator.pop(context),
          onDone: (resultBytes) => _navigateToFinalResult(context, resultBytes),
        ),
      ),
    );
  }

  void _navigateToFinalResult(BuildContext context, Uint8List resultBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalResultScreen(
          imageBytes: resultBytes,
          onHomePressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoSelectScreen(
        onImageSelected: (imageBytes) => _navigateToApplyEffects(context, imageBytes),
      ),
    );
  }
}
