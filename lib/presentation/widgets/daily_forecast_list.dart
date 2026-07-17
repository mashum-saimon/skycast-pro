import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/forecast_entity.dart';
import 'weather_icon_widget.dart';
import 'glass_card.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecastEntity> daily;

  const DailyForecastList({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final globalMin = daily.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
    final globalMax = daily.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);
    final range = (globalMax - globalMin).clamp(1, double.infinity);

    return GlassCard(
      dark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: List.generate(daily.length, (index) {
          final day = daily[index];
          final isToday = index == 0;
          final endFrac = (day.tempMax - globalMin) / range;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    isToday ? 'Today' : DateFormat.E().format(day.date),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                WeatherIconWidget(iconCode: day.icon, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${day.tempMin.round()}°',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: endFrac.clamp(0.05, 1.0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4FC3F7),
                                      Color(0xFFFFC371),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${day.tempMax.round()}°',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
