import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../entities/forecast_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecast {
  final WeatherRepository repository;
  GetForecast(this.repository);

  Future<Either<Failure, ForecastEntity>> call(double lat, double lon) {
    return repository.getForecast(lat, lon);
  }
}
