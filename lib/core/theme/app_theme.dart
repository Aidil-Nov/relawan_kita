import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color secondaryColor = Color(0xFFFF6F00);
  static const Color dangerColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: dangerColor,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      
      // KITA KOMENTARI DULU BAGIAN INI AGAR ERROR HILANG
      /* cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      */

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}