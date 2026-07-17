import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/failure.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/city_entity.dart';
import 'core_providers.dart';

enum WeatherStatus { initial, loading, refreshing, loaded, error, offline }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherEntity? weather;
  final ForecastEntity? forecast;
  final String? errorMessage;
  final bool isFromCache;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast,
    this.errorMessage,
    this.isFromCache = false,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    ForecastEntity? forecast,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, weather, forecast, errorMessage, isFromCache];
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final Ref ref;
  WeatherNotifier(this.ref) : super(const WeatherState());

  Future<void> loadByCity(String cityName, {bool isRefresh = false}) async {
    state = state.copyWith(
      status: isRefresh ? WeatherStatus.refreshing : WeatherStatus.loading,
    );

    final weatherResult = await ref.read(getCurrentWeatherProvider).call(cityName);

    await weatherResult.fold(
      (failure) async {
        state = state.copyWith(
          status: WeatherStatus.error,
          errorMessage: failure.message,
          isFromCache: failure is NetworkFailure,
        );
      },
      (weather) async {
        state = state.copyWith(
          status: WeatherStatus.loaded,
          weather: weather,
          isFromCache: false,
        );

        await ref.read(saveCityProvider).call(
              CityEntity(
                name: weather.cityName,
                country: weather.country,
                latitude: weather.latitude,
                longitude: weather.longitude,
                addedAt: DateTime.now(),
              ),
            );

        await ref.read(addRecentlyViewedActionProvider)(weather);

        final forecastResult = await ref
            .read(getForecastProvider)
            .call(weather.latitude, weather.longitude);

        forecastResult.fold(
          (_) {},
          (forecast) {
            state = state.copyWith(forecast: forecast);
          },
        );
      },
    );
  }

  Future<void> loadByLocation(double lat, double lon) async {
    state = state.copyWith(status: WeatherStatus.loading);

    final result =
        await ref.read(getCurrentWeatherByLocationProvider).call(lat, lon);

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: WeatherStatus.error,
          errorMessage: failure.message,
        );
      },
      (weather) async {
        state = state.copyWith(status: WeatherStatus.loaded, weather: weather);

        final forecastResult =
            await ref.read(getForecastProvider).call(lat, lon);
        forecastResult.fold((_) {}, (forecast) {
          state = state.copyWith(forecast: forecast);
        });
      },
    );
  }

  Future<void> refresh() async {
    final currentCity = state.weather?.cityName;
    if (currentCity != null) {
      await loadByCity(currentCity, isRefresh: true);
    }
  }
}

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>(
  (ref) => WeatherNotifier(ref),
);

/// Small helper provider so [WeatherNotifier] can add to "recently viewed"
/// without importing the repository directly.
final addRecentlyViewedActionProvider = Provider(
  (ref) => (WeatherEntity weather) {
    return ref.read(weatherRepositoryProvider).addRecentlyViewed(
          CityEntity(
            name: weather.cityName,
            country: weather.country,
            latitude: weather.latitude,
            longitude: weather.longitude,
            addedAt: DateTime.now(),
          ),
        );
  },
);
