import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color base) {
    return GoogleFonts.interTightTextTheme().copyWith(
      displayLarge: GoogleFonts.interTight(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: base,
      ),
      displayMedium: GoogleFonts.interTight(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: base,
      ),
      headlineLarge: GoogleFonts.interTight(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: base,
      ),
      headlineMedium: GoogleFonts.interTight(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleLarge: GoogleFonts.interTight(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: base),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: base),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: base.withOpacity(0.7)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: base),
    );
  }

  static ThemeData get light {
    const bg = AppColors.softGray;
    const onBg = AppColors.deepBlue;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.royalBlue,
      brightness: Brightness.light,
      primary: AppColors.royalBlue,
      secondary: AppColors.skyBlue,
      tertiary: AppColors.cyan,
      surface: Colors.white,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(onBg),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: AppColors.deepBlue.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.skyBlue, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(color: AppColors.slate.withOpacity(0.12)),
    );
  }

  static ThemeData get dark {
    const onBg = Colors.white;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.royalBlueLight,
      brightness: Brightness.dark,
      primary: AppColors.skyBlue,
      secondary: AppColors.cyan,
      tertiary: AppColors.royalBlueLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _textTheme(onBg),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.skyBlue,
        foregroundColor: AppColors.deepBlue,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.08)),
    );
  }
}
