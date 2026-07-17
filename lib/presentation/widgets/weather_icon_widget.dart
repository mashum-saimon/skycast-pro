import 'package:flutter/material.dart';

/// Maps OpenWeatherMap icon codes (e.g. "01d", "10n") to a polished
/// Material icon + color, with a gentle scale-in animation.
///
/// Using vector Material icons (rather than raster PNGs from the API)
/// keeps the UI crisp at every size and lets us theme icon color to
/// match the premium palette.
class WeatherIconWidget extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIconWidget({super.key, required this.iconCode, this.size = 64});

  IconData get _icon {
    final code = iconCode.substring(0, iconCode.length > 2 ? 2 : iconCode.length);
    final isNight = iconCode.endsWith('n');

    switch (code) {
      case '01':
        return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
      case '02':
        return isNight ? Icons.nights_stay_rounded : Icons.wb_cloudy_rounded;
      case '03':
      case '04':
        return Icons.cloud_rounded;
      case '09':
        return Icons.grain_rounded;
      case '10':
        return Icons.water_drop_rounded;
      case '11':
        return Icons.thunderstorm_rounded;
      case '13':
        return Icons.ac_unit_rounded;
      case '50':
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color get _color {
    final code = iconCode.substring(0, iconCode.length > 2 ? 2 : iconCode.length);
    switch (code) {
      case '01':
        return const Color(0xFFFFC371);
      case '02':
      case '03':
      case '04':
        return const Color(0xFFE2E8F0);
      case '09':
      case '10':
        return const Color(0xFF7DD3FC);
      case '11':
        return const Color(0xFFFBBF24);
      case '13':
        return const Color(0xFFE0F2FE);
      case '50':
        return const Color(0xFFCBD5E1);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Icon(_icon, size: size, color: _color),
    );
  }
}
