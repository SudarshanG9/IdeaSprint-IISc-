// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait lock only on mobile (no-op on web)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
  ));

  runApp(const ScanSpeakApp());
}

class ScanSpeakApp extends StatelessWidget {
  const ScanSpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanSpeak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Clamp text scale so layout doesn't break on high-dpi screens
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.25),
          ),
        ),
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}