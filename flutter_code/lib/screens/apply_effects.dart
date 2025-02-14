import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum FilterType { grayscale, sharpen, blur, edges }

// Define the function signatures
typedef ApplyGrayscaleFilterFunc = Bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);
typedef ApplyGrayscaleFilter = bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);

typedef ApplyBlurFilterFunc = Bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);
typedef ApplyBlurFilter = bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);

typedef ApplySharpenFilterFunc = Bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);
typedef ApplySharpenFilter = bool Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath);

class ImageProcessor {
  static DynamicLibrary? _lib;
  
  static void initializeLibraries() {
    if (_lib != null) return;

    if (Platform.isAndroid) {
      // Load OpenCV unified library first
      DynamicLibrary.open("libopencv_java4.so");
      
      // Then load our library
      _lib = DynamicLibrary.open("libeverpixel.so");
    } else {
      _lib = DynamicLibrary.process();
    }
  }

  static final ApplyGrayscaleFilter _applyGrayscaleFilter = _getGrayscaleFilter();
  static final ApplyBlurFilter _applyBlurFilter = _getBlurFilter();
  static final ApplySharpenFilter _applySharpenFilter = _getSharpenFilter();

  static ApplyGrayscaleFilter _getGrayscaleFilter() {
    initializeLibraries();
    return _lib!
      .lookup<NativeFunction<ApplyGrayscaleFilterFunc>>('applyGrayscaleFilter')
      .asFunction<ApplyGrayscaleFilter>();
  }

  static ApplyBlurFilter _getBlurFilter() {
    initializeLibraries();
    return _lib!
      .lookup<NativeFunction<ApplyBlurFilterFunc>>('applyBlurFilter')
      .asFunction<ApplyBlurFilter>();
  }

  static ApplySharpenFilter _getSharpenFilter() {
    initializeLibraries();
    return _lib!
      .lookup<NativeFunction<ApplySharpenFilterFunc>>('applySharpenFilter')
      .asFunction<ApplySharpenFilter>();
  }

  static bool applyGrayscale(String inputPath, String outputPath) {
    final inputPathPointer = inputPath.toNativeUtf8();
    final outputPathPointer = outputPath.toNativeUtf8();
    
    try {
      return _applyGrayscaleFilter(inputPathPointer, outputPathPointer);
    } finally {
      calloc.free(inputPathPointer);
      calloc.free(outputPathPointer);
    }
  }

  static bool applyBlur(String inputPath, String outputPath) {
    final inputPathPointer = inputPath.toNativeUtf8();
    final outputPathPointer = outputPath.toNativeUtf8();
    
    try {
      return _applyBlurFilter(inputPathPointer, outputPathPointer);
    } finally {
      calloc.free(inputPathPointer);
      calloc.free(outputPathPointer);
    }
  }

  static bool applySharpen(String inputPath, String outputPath) {
    final inputPathPointer = inputPath.toNativeUtf8();
    final outputPathPointer = outputPath.toNativeUtf8();
    
    try {
      return _applySharpenFilter(inputPathPointer, outputPathPointer);
    } finally {
      calloc.free(inputPathPointer);
      calloc.free(outputPathPointer);
    }
  }

  static Future<Uint8List?> applyEdgeDetection(Uint8List imageBytes) async {
    try {
      // Create multipart request
      var uri = Uri.parse('http://10.0.2.2:8000/process-image/');
      var request = http.MultipartRequest('POST', uri);
      
      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var jsonResponse = json.decode(utf8.decode(responseData));

      // Decode the base64 image
      String base64String = jsonResponse['processed_image'];
      return base64Decode(base64String);
    } catch (e) {
      print('Error in edge detection: $e');
      return null;
    }
  }
}

class ApplyEffectsScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback onBack; // Add this
  final Function(Uint8List) onDone; // Add this
  

  const ApplyEffectsScreen({
    super.key,
    required this.imageBytes,
    required this.onBack,
    required this.onDone, // Add this
  });

  @override
  State<ApplyEffectsScreen> createState() => _ApplyEffectsScreenState();
}

class _ApplyEffectsScreenState extends State<ApplyEffectsScreen> {
  FilterType? _selectedFilter;
  bool _isLoading = false;
  List<Uint8List> _imageHistory = [];
  int _currentHistoryIndex = 0;

  Future<bool> applySelectedFilter(String inputPath, String outputPath) async {
    switch (_selectedFilter) {
      case FilterType.grayscale:
        return ImageProcessor.applyGrayscale(inputPath, outputPath);
      case FilterType.blur:
        return ImageProcessor.applyBlur(inputPath, outputPath);
      case FilterType.sharpen:
        return ImageProcessor.applySharpen(inputPath, outputPath);
      case FilterType.edges:
        // Handle edge detection differently since it uses API
        final currentImageBytes = _imageHistory[_currentHistoryIndex];
        final processedImageBytes = await ImageProcessor.applyEdgeDetection(currentImageBytes);
        
        if (processedImageBytes != null) {
          // Save the processed image
          await File(outputPath).writeAsBytes(processedImageBytes);
          return true;
        }
        return false;
      default:
        return false;
    }
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
          onPressed: widget.onBack,
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
                final Directory tempDir = await getTemporaryDirectory();
                final String inputPath = path.join(tempDir.path, 'input_image.jpg');
                final String outputPath = path.join(tempDir.path, 'output_image.jpg');
                
                // Save current image to temporary file
                await File(inputPath).writeAsBytes(_imageHistory[_currentHistoryIndex]);
                
                // Apply selected filter
                final success = await applySelectedFilter(inputPath, outputPath);
                
                if (success) {
                  // Read the processed image
                  final Uint8List processedImage = await File(outputPath).readAsBytes();
                  
                  setState(() {
                    _imageHistory = _imageHistory.sublist(0, _currentHistoryIndex + 1)
                      ..add(processedImage);
                    _currentHistoryIndex++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to apply filter')),
                  );
                }
                
                // Clean up temporary files
                await File(inputPath).delete();
                await File(outputPath).delete();
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
        onPressed: () => widget.onDone(_imageHistory[_currentHistoryIndex]),
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