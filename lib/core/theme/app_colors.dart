import 'package:flutter/material.dart';

/// SkyCast Pro color system.
///
/// Primary   -> Deep Blue / Royal Blue
/// Accent    -> Sky Blue / Cyan
/// Secondary -> White / Soft Gray
class AppColors {
  AppColors._();

  // Primary
  static const Color deepBlue = Color(0xFF0B1A3A);
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color royalBlueLight = Color(0xFF3B5FCB);

  // Accent
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color cyan = Color(0xFF22D3EE);

  // Secondary
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGray = Color(0xFFF3F5F9);
  static const Color slate = Color(0xFF64748B);
  static const Color slateDark = Color(0xFF334155);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Dark surfaces
  static const Color darkBg = Color(0xFF070C1A);
  static const Color darkSurface = Color(0xFF101A33);
  static const Color darkCard = Color(0xFF16213E);

  // Glass overlays
  static Color glassLight = Colors.white.withOpacity(0.14);
  static Color glassBorderLight = Colors.white.withOpacity(0.28);
  static Color glassDark = Colors.white.withOpacity(0.06);
  static Color glassBorderDark = Colors.white.withOpacity(0.12);

  /// Weather-condition based gradient backgrounds.
  static List<Color> gradientFor(String condition, {bool isNight = false}) {
    final c = condition.toLowerCase();

    if (isNight) {
      return const [Color(0xFF05070F), Color(0xFF10173A), Color(0xFF1B2A6B)];
    }
    if (c.contains('clear') || c.contains('sun')) {
      return const [Color(0xFFFF9A56), Color(0xFFFFC371), Color(0xFFFFE29A)];
    }
    if (c.contains('rain') || c.contains('drizzle') || c.contains('thunder')) {
      return const [Color(0xFF2C3E82), Color(0xFF3E6BB0), Color(0xFF6FA8D6)];
    }
    if (c.contains('snow')) {
      return const [Color(0xFFDCE9F5), Color(0xFFAFC9E3), Color(0xFF87A8C9)];
    }
    if (c.contains('cloud')) {
      return const [Color(0xFF5C6B8A), Color(0xFF7C8CA8), Color(0xFFA3B1C6)];
    }
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
      return const [Color(0xFF7C8698), Color(0xFF9CA8B8), Color(0xFFBFC9D6)];
    }
    // default premium blue
    return const [AppColors.deepBlue, AppColors.royalBlue, AppColors.skyBlue];
  }
}
