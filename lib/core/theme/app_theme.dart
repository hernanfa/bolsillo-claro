import 'package:flutter/material.dart';

/// Paleta de colores, tipografía y constantes de diseño para Bolsillo Claro.
class AppTheme {
  AppTheme._();

  // Colores principales: Azul oscuro y Verde
  static const Color primaryDarkBlue = Color(0xFF0D253F); // Azul marino profundo
  static const Color secondaryDarkBlue = Color(0xFF1E3A5F); // Azul petróleo medio
  static const Color accentGreen = Color(0xFF059669); // Verde esmeralda principal
  static const Color lightGreen = Color(0xFF10B981); // Verde menta brillante
  static const Color surfaceGreen = Color(0xFFE6F4EA); // Fondo sutil verde
  
  // Colores neutrales y de superficie
  static const Color background = Color(0xFFF8FAFC); // Blanco pizarra
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Estados
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF059669);

  // Dimensiones consistentes
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryDarkBlue,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryDarkBlue,
        onPrimary: Colors.white,
        secondary: accentGreen,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 1,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: primaryDarkBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGreen,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: cardBorder),
        ),
      ),
    );
  }
}
