import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../entities/city_entity.dart';
import '../repositories/weather_repository.dart';

class SearchCity {
  final WeatherRepository repository;
  SearchCity(this.repository);

  Future<Either<Failure, List<CityEntity>>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Right(<CityEntity>[]));
    }
    return repository.searchCities(query.trim());
  }
}
