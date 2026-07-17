import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weather_provider.dart';
import '../providers/saved_cities_provider.dart';
import '../../domain/entities/city_entity.dart';
import '../widgets/animated_weather_background.dart';
import '../widgets/weather_icon_widget.dart';
import '../widgets/weather_metric_tile.dart';
import '../widgets/glass_card.dart';
import '../widgets/state_views.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherNotifierProvider);
    final weather = state.weather;
    final forecast = state.forecast;

    if (weather == null) {
      return Scaffold(
        body: ErrorStateView(
          message: 'No weather data available yet.',
          onRetry: () => context.pop(),
          icon: Icons.info_outline_rounded,
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${weather.cityName}, ${weather.country}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Consumer(
                        builder: (context, ref, _) {
                          final savedState = ref.watch(savedCitiesNotifierProvider);
                          final isFavorite = savedState.favorites.any(
                              (c) => c.name.toLowerCase() == weather.cityName.toLowerCase());
                          return IconButton(
                            onPressed: () {
                              if (isFavorite) {
                                final city = savedState.favorites.firstWhere(
                                    (c) => c.name.toLowerCase() == weather.cityName.toLowerCase());
                                ref.read(savedCitiesNotifierProvider.notifier).toggleFavorite(city.id!, false);
                              } else {
                                final city = CityEntity(
                                  name: weather.cityName,
                                  country: weather.country,
                                  latitude: weather.latitude,
                                  longitude: weather.longitude,
                                  isFavorite: true,
                                  addedAt: DateTime.now(),
                                );
                                ref.read(savedCitiesNotifierProvider.notifier).addCity(city);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${weather.cityName} added to favorites!'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? const Color(0xFFFF6B81) : theme.colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'weather-hero',
                        child: Material(
                          color: Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                WeatherIconWidget(iconCode: weather.icon, size: 120),
                                const SizedBox(height: 8),
                                Text(
                                  '${weather.temperature.round()}°',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  weather.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (forecast != null && forecast.hourly.isNotEmpty) ...[
                        const _SectionLabel('Temperature Trend'),
                        const SizedBox(height: 12),
                        _TemperatureChart(hourly: forecast.hourly),
                        const SizedBox(height: 28),
                      ],
                      const _SectionLabel('Sun & Sky'),
                      const SizedBox(height: 12),
                      _buildSunCard(weather, context),
                      const SizedBox(height: 20),
                      const _SectionLabel('Wind & Pressure'),
                      const SizedBox(height: 12),
                      WeatherMetricGrid(tiles: [
                        WeatherMetricTile(
                          icon: Icons.navigation_rounded,
                          label: 'Direction (${weather.windDirection})',
                          value: '${weather.windDegree}°',
                        ),
                        WeatherMetricTile(
                          icon: Icons.air_rounded,
                          label: 'Wind Speed',
                          value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                        ),
                        WeatherMetricTile(
                          icon: Icons.speed_rounded,
                          label: 'Pressure',
                          value: '${weather.pressure} hPa',
                        ),
                        WeatherMetricTile(
                          icon: Icons.water_drop_rounded,
                          label: 'Humidity',
                          value: '${weather.humidity}%',
                        ),
                        WeatherMetricTile(
                          icon: Icons.visibility_rounded,
                          label: 'Visibility',
                          value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                        ),
                        WeatherMetricTile(
                          icon: Icons.thermostat_rounded,
                          label: 'Feels Like',
                          value: '${weather.feelsLike.round()}°',
                        ),
                        WeatherMetricTile(
                          icon: Icons.wb_twilight_rounded,
                          label: 'UV Index',
                          value: weather.uvIndex?.toStringAsFixed(1) ?? 'N/A',
                        ),
                        WeatherMetricTile(
                          icon: Icons.grain_rounded,
                          label: 'Chance of Rain',
                          value: forecast != null && forecast.daily.isNotEmpty
                              ? '${(forecast.daily.first.pop * 100).round()}%'
                              : 'N/A',
                        ),
                        WeatherMetricTile(
                          icon: Icons.air_outlined,
                          label: 'Air Quality',
                          value: weather.aqiLabel,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildSunCard(dynamic weather, BuildContext context) {
    final localSunrise = weather.sunrise.add(Duration(seconds: weather.timezoneOffset as int));
    final localSunset = weather.sunset.add(Duration(seconds: weather.timezoneOffset as int));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      dark: isDark,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFC371), size: 20),
                    const SizedBox(width: 6),
                    Text('Sunrise', style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat.jm().format(localSunrise),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.nightlight_round, color: Color(0xFFB4C6EF), size: 20),
                    const SizedBox(width: 6),
                    Text('Sunset', style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat.jm().format(localSunset),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TemperatureChart extends StatelessWidget {
  final List<dynamic> hourly;
  const _TemperatureChart({required this.hourly});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final spots = <FlSpot>[
      for (var i = 0; i < hourly.length; i++)
        FlSpot(i.toDouble(), (hourly[i].temperature as double)),
    ];

    return GlassCard(
      dark: isDark,
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= hourly.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat.j().format(hourly[index].dateTime as DateTime),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
