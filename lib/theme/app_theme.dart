import 'package:flutter/material.dart';

class AppTheme {
  // Gather colors
  static const Color primaryColor = Color(0xFFFF725E);
  static const Color backgroundColor = Color(0xFFFAF7F2);
  static const Color secondaryColor = Color(0xFF55B6B2);
  static const Color successColor = Color(0xFFD7F3E3);
  static const Color textColor = Color(0xFF242424);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
      onSurface: textColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),

    scaffoldBackgroundColor: backgroundColor,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),
  );
}