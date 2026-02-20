import 'package:flutter/material.dart';
import 'screens/core_theme.dart';
import 'screens/boot_screen.dart';

void main() {
  runApp(const AurumApp());
}

class AurumApp extends StatelessWidget {
  const AurumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurum FO Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // THE MASTER SWITCH: This forces the entire app to use the new Tactical Ceramic background!
        scaffoldBackgroundColor: AXTheme.bg,
        brightness: Brightness.dark,
      ),
      // App starts from the Boot Screen
      home: const SystemBootScreen(),
    );
  }
}
