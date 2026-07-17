import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/forecast_entity.dart';
import 'weather_icon_widget.dart';
import 'glass_card.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecastEntity> hourly;

  const HourlyForecastList({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = hourly[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + index * 80),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 16),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: 74,
              child: GlassCard(
                dark: isDark,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                borderRadius: 22,
                blur: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.j().format(item.dateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WeatherIconWidget(iconCode: item.icon, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      '${item.temperature.round()}°',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
