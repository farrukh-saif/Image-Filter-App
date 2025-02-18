import 'dart:typed_data';
import 'package:flutter/material.dart';

class FinalResultScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const FinalResultScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CAB3),
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: const Color(0xFFD9CAB3),
        title: const Text(
          'Final Result',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.black, size: 35),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              color: const Color(0xFFF5F5DC),
              padding: EdgeInsets.zero,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
