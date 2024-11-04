import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F6F9);
  static const Color cardColor = Colors.white;
  static const Color darkPrimaryColor = Color(0xFF3F3D56);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSurface: Colors.black87,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: secondaryColor,
      surface: darkCardColor,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
  );

  static ThemeMode getThemeMode(String? themeString) {
    switch (themeString?.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}