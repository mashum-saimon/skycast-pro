import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeather {
  final WeatherRepository repository;
  GetCurrentWeather(this.repository);

  Future<Either<Failure, WeatherEntity>> call(String cityName) {
    return repository.getCurrentWeather(cityName);
  }
}

class GetCurrentWeatherByLocation {
  final WeatherRepository repository;
  GetCurrentWeatherByLocation(this.repository);

  Future<Either<Failure, WeatherEntity>> call(double lat, double lon) {
    return repository.getCurrentWeatherByLocation(lat, lon);
  }
}
