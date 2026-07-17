import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A frosted glass container used throughout the app for premium,
/// translucent cards over gradient backgrounds.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final bool dark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.blur = 18,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: dark ? AppColors.glassDark : AppColors.glassLight,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
