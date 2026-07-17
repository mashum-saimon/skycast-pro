import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/city_entity.dart';
import '../providers/weather_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/saved_cities_provider.dart';
import '../providers/core_providers.dart';
import '../widgets/animated_weather_background.dart';
import '../widgets/weather_icon_widget.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/weather_metric_tile.dart';
import '../widgets/offline_banner.dart';
import '../widgets/state_views.dart';
import '../widgets/glass_card.dart';
import '../widgets/city_list_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final state = ref.read(weatherNotifierProvider);
    if (state.weather != null) return;

    final locationService = ref.read(locationServiceProvider);
    final positionResult = await locationService.getCurrentPosition();

    positionResult.fold(
      (_) => ref.read(weatherNotifierProvider.notifier).loadByCity('London'),
      (position) => ref
          .read(weatherNotifierProvider.notifier)
          .loadByLocation(position.latitude, position.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final isOnline = ref.watch(isOnlineSnapshotProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildTopBar(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.royalBlue,
                  backgroundColor: Colors.white,
                  onRefresh: () => ref.read(weatherNotifierProvider.notifier).refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: OfflineBanner(visible: !isOnline || weatherState.isFromCache),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildBody(context, weatherState),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/search'),
        child: const Icon(Icons.search_rounded),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'SkyCast Pro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () => context.push('/settings'),
              icon: Icon(Icons.settings, size: 18, color: theme.colorScheme.onPrimary),
              label: Text('Settings', style: TextStyle(color: theme.colorScheme.onPrimary)),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _bootstrapWithFreshLocation,
              icon: Icon(Icons.my_location_rounded, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _bootstrapWithFreshLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final positionResult = await locationService.getCurrentPosition();
    positionResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (position) => ref
          .read(weatherNotifierProvider.notifier)
          .loadByLocation(position.latitude, position.longitude),
    );
  }

  Widget _buildBody(BuildContext context, WeatherState state) {
    switch (state.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 40),
          child: WeatherLoadingView(),
        );
      case WeatherStatus.error:
        if (state.weather == null) {
          return SizedBox(
            height: 500,
            child: ErrorStateView(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () => ref.read(weatherNotifierProvider.notifier).refresh(),
            ),
          );
        }
        continue loaded;
      loaded:
      case WeatherStatus.loaded:
      case WeatherStatus.refreshing:
        final weather = state.weather!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(weather),
              const SizedBox(height: 24),
              WeatherMetricGrid(tiles: [
                WeatherMetricTile(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                WeatherMetricTile(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                ),
                WeatherMetricTile(
                  icon: Icons.speed_rounded,
                  label: 'Pressure',
                  value: '${weather.pressure} hPa',
                ),
                WeatherMetricTile(
                  icon: Icons.thermostat_rounded,
                  label: 'Feels Like',
                  value: '${weather.feelsLike.round()}°',
                ),
                WeatherMetricTile(
                  icon: Icons.visibility_rounded,
                  label: 'Visibility',
                  value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                ),
                WeatherMetricTile(
                  icon: Icons.air_outlined,
                  label: 'Air Quality',
                  value: weather.aqiLabel,
                ),
              ]),
              const SizedBox(height: 24),
              if (state.forecast != null) ...[
                _sectionTitle('Hourly Forecast', context),
                const SizedBox(height: 12),
                HourlyForecastList(hourly: state.forecast!.hourly),
                const SizedBox(height: 24),
                _sectionTitle('7-Day Forecast', context),
                const SizedBox(height: 12),
                DailyForecastList(daily: state.forecast!.daily),
                const SizedBox(height: 24),
              ],
              _buildFavoritesSection(context),
              const SizedBox(height: 24),
              _buildRecentSection(context),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHero(dynamic weather) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/detail'),
      child: Hero(
        tag: 'weather-hero',
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${weather.cityName}, ${weather.country}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final savedState = ref.watch(savedCitiesNotifierProvider);
                      final isFavorite = savedState.favorites.any((c) =>
                          c.name.toLowerCase() == weather.cityName.toLowerCase());
                      return IconButton(
                        onPressed: () {
                          if (isFavorite) {
                            final city = savedState.favorites.firstWhere((c) =>
                                c.name.toLowerCase() == weather.cityName.toLowerCase());
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
              const SizedBox(height: 12),
              WeatherIconWidget(iconCode: weather.icon, size: 96),
              const SizedBox(height: 8),
              Text(
                '${weather.temperature.round()}°',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  height: 1,
                ),
              ),
              Text(
                weather.description.isNotEmpty
                    ? weather.description[0].toUpperCase() + weather.description.substring(1)
                    : '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'H:${weather.tempMax.round()}°  L:${weather.tempMin.round()}°',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    final savedState = ref.watch(savedCitiesNotifierProvider);
    final favorites = savedState.favorites;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Favorite Cities', context),
        const SizedBox(height: 12),
        if (favorites.isEmpty)
          GlassCard(
            dark: isDark,
            child: Text(
              'Tap the heart icon on any saved city to pin it here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final city = favorites[index];
                return SizedBox(
                  width: 320,
                  child: CityListTile(
                    city: city,
                    onTap: () => ref
                        .read(weatherNotifierProvider.notifier)
                        .loadByCity(city.name),
                    onFavoriteToggle: () => ref
                        .read(savedCitiesNotifierProvider.notifier)
                        .toggleFavorite(city.id!, !city.isFavorite),
                    onRename: () => _showRenameDialog(city.id!, city.displayName),
                    onDelete: () => ref
                        .read(savedCitiesNotifierProvider.notifier)
                        .deleteCity(city.id!),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final recentAsync = ref.watch(recentlyViewedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Recently Viewed', context),
        const SizedBox(height: 12),
        recentAsync.when(
          data: (cities) {
            if (cities.isEmpty) {
              return GlassCard(
                dark: isDark,
                child: Text(
                  'Cities you check will show up here.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ActionChip(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    label: Text(
                      city.name,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    onPressed: () => ref
                        .read(weatherNotifierProvider.notifier)
                        .loadByCity(city.name),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showRenameDialog(int id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Rename City'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(savedCitiesNotifierProvider.notifier)
                  .renameCity(id, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
