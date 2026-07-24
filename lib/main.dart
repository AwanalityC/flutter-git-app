import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// This is the very first thing that runs when the app starts.
void main() {
  runApp(const ShadowDiaryApp());
}

class ShadowDiaryApp extends StatelessWidget {
  const ShadowDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root widget that gives us theming, navigation, etc.
    return MaterialApp(
      title: 'Shadow Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C63FF),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}