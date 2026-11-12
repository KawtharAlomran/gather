import 'package:flutter/material.dart';

class AppTheme {
  // Gather colors
  static const Color primaryColor = Color(0xFFFF725E);
  static const Color backgroundColor = Color(0xFFFAF7F2);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color secondaryColor = Color(0xFF55B6B2);
  static const Color successColor = Color(0xFFD7F3E3);
  static const Color textColor = Color(0xFF242424);
  static const Color secondaryButtonColor = Color(0xFFF0EDE9);
  static const Color secondaryButtonTextColor = Color(0xFF78716D);
  static const Color successTextColor = Color(0xFF256B45);
  static const Color errorColor = Color(0xFFF8DEDC);
  static const Color errorTextColor = Color(0xFF9E302B);


  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: textColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: surfaceColor,
    indicatorColor: primaryColor,
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

      titleMedium: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
    ),
  );
}
