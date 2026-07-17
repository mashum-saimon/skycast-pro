import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Smoothly animates between weather-condition based gradients whenever
/// [condition] or [isNight] changes, giving the app its signature
/// "living background" feel.
class AnimatedWeatherBackground extends StatelessWidget {
  final String condition;
  final bool isNight;
  final Widget child;

  const AnimatedWeatherBackground({
    super.key,
    required this.condition,
    required this.isNight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientFor(condition, isNight: isNight);

    return TweenAnimationBuilder<double>(
      key: ValueKey('$condition-$isNight'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;
  const _Orb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
