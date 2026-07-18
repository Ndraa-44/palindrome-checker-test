import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette from Design System
  static const Color primaryColor = Color(0xFF1B1B2F);
  static const Color secondaryColor = Color(0xFF8B8D98);
  static const Color tertiaryColor = Color(0xFF6B5CA5);
  static const Color neutralColor = Color(0xFF787678);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8BAEAF), // Soft teal 
      Color(0xFF8884A4), // Soft purple/grey
    ],
  );

  static const Color textPrimaryColor = Color(0xFF1B1B2F);
  static const Color hintTextColor = Color(0xFF8B8D98);
}
