import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../database/database_helper.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_forecast.dart';
import '../../domain/usecases/search_city.dart';
import '../../domain/usecases/manage_saved_cities.dart';
import '../../services/location_service.dart';

// ---------------------------------------------------------------------
// Core / infrastructure
// ---------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

// ---------------------------------------------------------------------
// Data sources
// ---------------------------------------------------------------------

final remoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => WeatherRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final localDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) => WeatherLocalDataSourceImpl(ref.watch(databaseHelperProvider)),
);

// ---------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remote: ref.watch(remoteDataSourceProvider),
    local: ref.watch(localDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ---------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------

final getCurrentWeatherProvider = Provider<GetCurrentWeather>(
  (ref) => GetCurrentWeather(ref.watch(weatherRepositoryProvider)),
);

final getCurrentWeatherByLocationProvider =
    Provider<GetCurrentWeatherByLocation>(
  (ref) => GetCurrentWeatherByLocation(ref.watch(weatherRepositoryProvider)),
);

final getForecastProvider = Provider<GetForecast>(
  (ref) => GetForecast(ref.watch(weatherRepositoryProvider)),
);

final searchCityProvider = Provider<SearchCity>(
  (ref) => SearchCity(ref.watch(weatherRepositoryProvider)),
);

final saveCityProvider = Provider<SaveCity>(
  (ref) => SaveCity(ref.watch(weatherRepositoryProvider)),
);

final getSavedCitiesProvider = Provider<GetSavedCities>(
  (ref) => GetSavedCities(ref.watch(weatherRepositoryProvider)),
);

final getFavoriteCitiesProvider = Provider<GetFavoriteCities>(
  (ref) => GetFavoriteCities(ref.watch(weatherRepositoryProvider)),
);

final updateCityNicknameProvider = Provider<UpdateCityNickname>(
  (ref) => UpdateCityNickname(ref.watch(weatherRepositoryProvider)),
);

final toggleFavoriteCityProvider = Provider<ToggleFavoriteCity>(
  (ref) => ToggleFavoriteCity(ref.watch(weatherRepositoryProvider)),
);

final deleteCityProvider = Provider<DeleteCity>(
  (ref) => DeleteCity(ref.watch(weatherRepositoryProvider)),
);
