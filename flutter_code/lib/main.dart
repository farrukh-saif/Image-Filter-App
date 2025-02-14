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
      home: const MainNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  final List<Widget> _pages = [];

  void _pushPage(Widget page) => setState(() => _pages.add(page));
  void _popPage() => setState(() => _pages.removeLast());
  void _goHome() => setState(() => _pages.clear());

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          child: PhotoSelectScreen(
            onImageSelected: (bytes) => _pushPage(
              ApplyEffectsScreen(
                imageBytes: bytes,
                onBack: _popPage,
                onDone: (resultBytes) => _pushPage(
                  FinalResultScreen(
                    imageBytes: resultBytes,
                    onHomePressed: _goHome,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_pages.isNotEmpty) ..._pages.map((p) => MaterialPage(child: p))
      ],
      onPopPage: (route, result) {
        if (_pages.isNotEmpty) _popPage();
        return route.didPop(result);
      },
    );
  }
}