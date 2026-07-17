import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import '../entities/city_entity.dart';
import '../repositories/weather_repository.dart';

/// CREATE
class SaveCity {
  final WeatherRepository repository;
  SaveCity(this.repository);

  Future<Either<Failure, CityEntity>> call(CityEntity city) {
    return repository.saveCity(city);
  }
}

/// READ (all saved cities)
class GetSavedCities {
  final WeatherRepository repository;
  GetSavedCities(this.repository);

  Future<Either<Failure, List<CityEntity>>> call() {
    return repository.getSavedCities();
  }
}

/// READ (favorites only)
class GetFavoriteCities {
  final WeatherRepository repository;
  GetFavoriteCities(this.repository);

  Future<Either<Failure, List<CityEntity>>> call() {
    return repository.getFavoriteCities();
  }
}

/// UPDATE (nickname / rename)
class UpdateCityNickname {
  final WeatherRepository repository;
  UpdateCityNickname(this.repository);

  Future<Either<Failure, CityEntity>> call(int id, String nickname) {
    return repository.updateCityNickname(id, nickname);
  }
}

/// UPDATE (favorite toggle)
class ToggleFavoriteCity {
  final WeatherRepository repository;
  ToggleFavoriteCity(this.repository);

  Future<Either<Failure, bool>> call(int id, bool isFavorite) {
    return repository.toggleFavorite(id, isFavorite);
  }
}

/// DELETE
class DeleteCity {
  final WeatherRepository repository;
  DeleteCity(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteCity(id);
  }
}
