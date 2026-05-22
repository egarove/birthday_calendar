import 'package:flutter/material.dart';

class AppTheme {

  static const primaryColor = Color(0xFF373D20);
  static const secundaryColor = Color(0xFF717744);
  static const surfaceColor = Color(0xFFBCBD8B);
  static const backgroundColor = Color(0xFFEFF1ED);
  static const errorColor = Color(0xFF766153);

  static ThemeData lightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 25,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secundaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secundaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: primaryColor),
        bodySmall: TextStyle(color: secundaryColor),
      ),

      iconTheme: const IconThemeData(color: primaryColor),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}