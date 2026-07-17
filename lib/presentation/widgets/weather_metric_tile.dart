import 'package:flutter/material.dart';
import 'glass_card.dart';

class WeatherMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      dark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: 20,
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary.withOpacity(0.8), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class WeatherMetricGrid extends StatelessWidget {
  final List<WeatherMetricTile> tiles;

  const WeatherMetricGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: tiles,
    );
  }
}
