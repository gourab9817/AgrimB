import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.orange,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    fontFamily: 'Satoshi',

    // Update input decoration theme to better match the design
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      labelStyle: TextStyle(
        color: AppColors.brown,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.brown.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      // Default border style - underline for most text fields
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.orange,
          width: 2.0,
        ),
      ),
    ),

    // ElevatedButtonTheme that ALL ElevatedButtons (including BasicAppButton) will inherit
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,      // Button color
        foregroundColor: AppColors.brown,       // Text/icon color
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size.fromHeight(50), // Default button height
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        elevation: 0, // No shadow as per design
      ),
    ),
    
    // Text styles for consistent typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    ),
  );
}