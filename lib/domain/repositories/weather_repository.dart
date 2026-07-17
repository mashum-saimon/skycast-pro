import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../entities/weather_entity.dart';
import '../entities/forecast_entity.dart';
import '../entities/city_entity.dart';

abstract class WeatherRepository {
  /// Fetches current weather for a city name. Falls back to cache when offline.
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(String cityName);

  /// Fetches current weather from raw coordinates (GPS).
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByLocation(
    double lat,
    double lon,
  );

  /// Fetches hourly + daily forecast for a city.
  Future<Either<Failure, ForecastEntity>> getForecast(
    double lat,
    double lon,
  );

  /// City name search / geocoding, with debouncing handled by the caller.
  Future<Either<Failure, List<CityEntity>>> searchCities(String query);

  // ---------------- SQLite CRUD ----------------

  Future<Either<Failure, List<CityEntity>>> getSavedCities();

  Future<Either<Failure, List<CityEntity>>> getFavoriteCities();

  Future<Either<Failure, CityEntity>> saveCity(CityEntity city);

  Future<Either<Failure, CityEntity>> updateCityNickname(
    int id,
    String nickname,
  );

  Future<Either<Failure, bool>> toggleFavorite(int id, bool isFavorite);

  Future<Either<Failure, bool>> deleteCity(int id);

  // ---------------- Search history ----------------

  Future<Either<Failure, List<String>>> getSearchHistory();

  Future<Either<Failure, bool>> addSearchHistory(String query);

  Future<Either<Failure, bool>> clearSearchHistory();

  // ---------------- Recently viewed ----------------

  Future<Either<Failure, List<CityEntity>>> getRecentlyViewed();

  Future<Either<Failure, bool>> addRecentlyViewed(CityEntity city);

  // ---------------- Cache ----------------

  Future<Either<Failure, WeatherEntity>> getCachedWeather(String cityName);

  Future<Either<Failure, bool>> cacheWeather(WeatherEntity weather);
}
