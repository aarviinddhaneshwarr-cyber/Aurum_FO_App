import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// अपनी बनाई हुई फाइल्स को जोड़ रहे हैं
import 'screens/core_theme.dart';
import 'screens/boot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AurumFOApp());
}

class AurumFOApp extends StatelessWidget {
  const AurumFOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurum FO Protocol',
      theme:
          ThemeData.dark().copyWith(scaffoldBackgroundColor: AXTheme.titanium),
      home: const SystemBootScreen(),
    );
  }
}
