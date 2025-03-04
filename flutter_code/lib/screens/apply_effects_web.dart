import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'final_result.dart';
//JS Interop - Part of the core libraries - The main library used for dart-JS interoperability
import 'dart:js_interop';
import 'dart:html' as html;

enum FilterType { grayscale, sharpen, blur, edges }

@JS('applyGrayscaleFilter')
external String applyGrayscaleFilter();

@JS('applyBlurFilter')
external String applyBlurFilter();

@JS('applySharpenFilter')
external String applySharpenFilter();

@JS('applyEdgeDetectionFilter')
external String applyEdgeDetectionFilter();


class ApplyEffectsScreen extends StatefulWidget {
  final Uint8List imageBytes;
  

  const ApplyEffectsScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ApplyEffectsScreen> createState() => _ApplyEffectsScreenState();
}

class _ApplyEffectsScreenState extends State<ApplyEffectsScreen> {
  FilterType? _selectedFilter;
  bool _isLoading = false;
  List<Uint8List> _imageHistory = [];
  int _currentHistoryIndex = 0;

  Future<void> _updateSourceImage() async {
    // Create a blob from the image bytes
    final blob = html.Blob([_imageHistory[_currentHistoryIndex]]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Get the source image element and update its src
    final imageElement = html.document.getElementById('srcImage') as html.ImageElement;
    imageElement.src = url;

    // Wait for image to load before returning
    await imageElement.onLoad.first;
  }


  Future<bool> applySelectedFilter() async {
    await _updateSourceImage(); // Wait for source image to load
    String base64Image ="";
    switch (_selectedFilter) {
      case FilterType.grayscale:
        base64Image = applyGrayscaleFilter();
      case FilterType.sharpen:
        base64Image = applySharpenFilter();
      case FilterType.blur:
        base64Image = applyBlurFilter();
      case FilterType.edges:
        base64Image = applyEdgeDetectionFilter();
      default:
        return false;
    }

    setState(() { 
      _imageHistory = _imageHistory.sublist(0, _currentHistoryIndex + 1)
          ..add(base64Decode(base64Image.split(',')[1]));
      _currentHistoryIndex += 1;
    });
    print("Applying filter of type: $_selectedFilter");
    return true;
  }

  @override
  void initState() {
    super.initState();
    _imageHistory = [widget.imageBytes]; // Initialize with original
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CAB3), // Main background color
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFFD9CAB3), // Match background
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.undo, 
                color: _currentHistoryIndex > 0 ? Colors.black : Colors.grey),
              onPressed: _currentHistoryIndex > 0 ? () {
                setState(() => _currentHistoryIndex--);
              } : null,
            ),
            IconButton(
              icon: Icon(Icons.redo,
                color: _currentHistoryIndex < _imageHistory.length - 1 ? Colors.black : Colors.grey),
              onPressed: _currentHistoryIndex < _imageHistory.length - 1 ? () {
                setState(() => _currentHistoryIndex++);
              } : null,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_selectedFilter == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a filter first')),
                );
                return;
              }
              
              setState(() => _isLoading = true);
              
              try {
                // Apply selected filter
                await applySelectedFilter();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                  _selectedFilter = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212121),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => {Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinalResultScreen(
                  imageBytes: _imageHistory[_currentHistoryIndex],
                ),
              ),
            )},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: const Color(0xFF212121),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Image Section
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5DC), // Beige image background
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Image.memory(
                      _imageHistory[_currentHistoryIndex],
                      fit: BoxFit.contain,
                    ),
                    if (_isLoading)
                      Center(child: const CircularProgressIndicator(color: Colors.black)),
                  ],
              ),
            ),
          ),
          
          // Bottom Controls Strip
          Container(
            height: 110,
            color: Color(0xFF212121),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEffectButton(FilterType.grayscale, 'Grayscale'),
                _buildEffectButton(FilterType.sharpen, 'Sharpen'),
                _buildEffectButton(FilterType.blur, 'Blur'),
                _buildEffectButton(FilterType.edges, 'Edges'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectButton(FilterType type, String text) {
    final isSelected = _selectedFilter == type;

    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
          ? const Color(0xFF4A766E)  // Darker shade when selected
          : const Color(0xFF6D9886),
        padding: EdgeInsets.zero, // Remove internal padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(0),
        alignment: Alignment.center,
        width: 80,
        height: 80,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}