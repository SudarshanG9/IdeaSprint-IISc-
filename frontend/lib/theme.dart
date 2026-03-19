// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color background  = Color(0xFF0A0A0F);
  static const Color surface     = Color(0xFF141420);
  static const Color primary     = Color(0xFF00E5A0);
  static const Color secondary   = Color(0xFFFFD166);
  static const Color danger      = Color(0xFFFF5F5F);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color cardBg      = Color(0xFF1C1C2E);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
      titleLarge:     TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      bodyLarge:      TextStyle(fontSize: 18, color: textPrimary, height: 1.5),
      bodyMedium:     TextStyle(fontSize: 16, color: textSecondary, height: 1.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary, size: 28),
    ),
  );
}

class AppStrings {
  static const appName          = 'ScanSpeak';
  static const tapToScan        = 'Tap to Scan Product';
  static const scanning         = 'Scanning…';
  static const productDetected  = 'Product detected';
  static const playingDesc      = 'Playing description';
  static const replay           = 'Replay';
  static const pause            = 'Pause';
  static const resume           = 'Resume';
  static const moreDetails      = 'More Details';
  static const scanAnother      = 'Scan Another';
  static const settings         = 'Language Settings';
}