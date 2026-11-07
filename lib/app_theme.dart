import 'package:flutter/material.dart';

class SpendColors {
  static const canvas = Color(0xFFEEF1ED);
  static const surface = Color(0xFFFBFCF8);
  static const ink = Color(0xFF17231D);
  static const inkSubtle = Color(0xFF56635C);
  static const muted = Color(0xFF87928C);
  static const line = Color(0xFFE2E7E1);
  static const brand = Color(0xFF173F32);
  static const brandSoft = Color(0xFFDCE9E1);
  static const lime = Color(0xFFC8E26B);
  static const positive = Color(0xFF2C8A64);
  static const positiveSoft = Color(0xFFE0F3E9);
  static const danger = Color(0xFFC4554D);
  static const dangerSoft = Color(0xFFF8E7E5);
}

ThemeData spendWiseTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: SpendColors.brand,
    brightness: Brightness.light,
    surface: SpendColors.surface,
  ).copyWith(
    primary: SpendColors.brand,
    secondary: SpendColors.lime,
    error: SpendColors.danger,
    outline: SpendColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SpendColors.surface,
    fontFamily: 'sans-serif',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: SpendColors.ink,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(
        color: SpendColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: SpendColors.ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: SpendColors.inkSubtle, fontSize: 13),
      bodySmall: TextStyle(color: SpendColors.muted, fontSize: 11),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SpendColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SpendColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SpendColors.positive, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SpendColors.line),
      ),
    ),
  );
}
