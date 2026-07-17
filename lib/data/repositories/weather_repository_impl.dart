import 'package:dartz/dartz.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/failure.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_local_datasource.dart';
import '../models/weather_model.dart';
import '../models/city_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remote;
  final WeatherLocalDataSource local;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String cityName,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final weather = await remote.getCurrentWeatherByCity(cityName);
        await local.cacheWeather(weather);
        return Right(weather);
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ApiKeyException catch (e) {
        return Left(ApiKeyFailure(e.message));
      } on RateLimitException catch (e) {
        return Left(RateLimitFailure(e.message));
      } on NetworkException {
        return _fallbackToCache(cityName);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    } else {
      return _fallbackToCache(cityName);
    }
  }

  Future<Either<Failure, WeatherEntity>> _fallbackToCache(
    String cityName,
  ) async {
    try {
      final cached = await local.getCachedWeather(cityName);
      return Right(cached);
    } catch (_) {
      return const Left(
        NetworkFailure('You are offline and no cached data was found.'),
      );
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeatherByLocation(
    double lat,
    double lon,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final weather = await remote.getCurrentWeatherByCoords(lat, lon);
      await local.cacheWeather(weather);
      return Right(weather);
    } on ApiKeyException catch (e) {
      return Left(ApiKeyFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ForecastEntity>> getForecast(
    double lat,
    double lon,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final forecast = await remote.getForecast(lat, lon);
      return Right(forecast);
    } on ApiKeyException catch (e) {
      return Left(ApiKeyFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> searchCities(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Search requires an internet connection.'));
    }
    try {
      final results = await remote.searchCities(query);
      return Right(results);
    } on ApiKeyException catch (e) {
      return Left(ApiKeyFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  // ---------------------------------------------------------------------
  // SQLite CRUD
  // ---------------------------------------------------------------------

  @override
  Future<Either<Failure, List<CityEntity>>> getSavedCities() async {
    try {
      final cities = await local.getSavedCities();
      return Right(cities);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getFavoriteCities() async {
    try {
      final cities = await local.getFavoriteCities();
      return Right(cities);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CityEntity>> saveCity(CityEntity city) async {
    try {
      final saved = await local.saveCity(CityModel.fromEntity(city));
      return Right(saved);
    } catch (_) {
      return const Left(
        CacheFailure('This city is already saved or could not be added.'),
      );
    }
  }

  @override
  Future<Either<Failure, CityEntity>> updateCityNickname(
    int id,
    String nickname,
  ) async {
    try {
      final updated = await local.updateCityNickname(id, nickname);
      return Right(updated);
    } catch (_) {
      return const Left(CacheFailure('Unable to rename this city.'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(
    int id,
    bool isFavorite,
  ) async {
    try {
      final result = await local.toggleFavorite(id, isFavorite);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCity(int id) async {
    try {
      final result = await local.deleteCity(id);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  // ---------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------

  @override
  Future<Either<Failure, List<String>>> getSearchHistory() async {
    try {
      final history = await local.getSearchHistory();
      return Right(history);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addSearchHistory(String query) async {
    try {
      final result = await local.addSearchHistory(query);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> clearSearchHistory() async {
    try {
      final result = await local.clearSearchHistory();
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  // ---------------------------------------------------------------------
  // Recently viewed
  // ---------------------------------------------------------------------

  @override
  Future<Either<Failure, List<CityEntity>>> getRecentlyViewed() async {
    try {
      final list = await local.getRecentlyViewed();
      return Right(list);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addRecentlyViewed(CityEntity city) async {
    try {
      final result = await local.addRecentlyViewed(CityModel.fromEntity(city));
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  // ---------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------

  @override
  Future<Either<Failure, WeatherEntity>> getCachedWeather(
    String cityName,
  ) async {
    try {
      final cached = await local.getCachedWeather(cityName);
      return Right(cached);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> cacheWeather(WeatherEntity weather) async {
    try {
      final model = weather is WeatherModel
          ? weather
          : WeatherModel(
              cityName: weather.cityName,
              country: weather.country,
              latitude: weather.latitude,
              longitude: weather.longitude,
              temperature: weather.temperature,
              feelsLike: weather.feelsLike,
              tempMin: weather.tempMin,
              tempMax: weather.tempMax,
              condition: weather.condition,
              description: weather.description,
              icon: weather.icon,
              humidity: weather.humidity,
              windSpeed: weather.windSpeed,
              windDegree: weather.windDegree,
              pressure: weather.pressure,
              visibility: weather.visibility,
              uvIndex: weather.uvIndex,
              aqi: weather.aqi,
              sunrise: weather.sunrise,
              sunset: weather.sunset,
              timestamp: weather.timestamp,
              timezoneOffset: weather.timezoneOffset,
            );
      final result = await local.cacheWeather(model);
      return Right(result);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
