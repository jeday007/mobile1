import 'package:flutter/material.dart';

abstract final class DosezyTheme {
  static const _blue = Color(0xFF0277BD);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: Brightness.light,
      surface: Colors.white,
    ).copyWith(
      primary: _blue,
      primaryContainer: const Color(0xFF4FC3F7),
      onPrimaryContainer: Colors.black,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4FC3F7),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF4FC3F7),
      primaryContainer: _blue,
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
