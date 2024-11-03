import 'package:flutter/material.dart';

// Color schemes
const Color primaryColor = Color(0xFF6C63FF);
const Color secondaryColor = Color(0xFF4CAF50);
const Color backgroundColor = Color(0xFFF5F6F9);
const Color cardColor = Colors.white;
const Color darkPrimaryColor = Color(0xFF3F3D56);
const Color darkBackgroundColor = Color(0xFF121212);
const Color darkCardColor = Color(0xFF1E1E1E);

// Text styles
class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle message = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle score = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}

// Decorations
class AppDecorations {
  static BoxDecoration card(bool isDark) => BoxDecoration(
    color: isDark ? darkCardColor : cardColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 10,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration badge(bool isDark) => BoxDecoration(
    color: (isDark ? darkPrimaryColor : primaryColor).withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  );
}

// Padding
class AppPadding {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}