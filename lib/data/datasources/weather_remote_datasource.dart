
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/city_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeatherByCity(String cityName);
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon);
  Future<ForecastModel> getForecast(double lat, double lon);
  Future<List<CityModel>> searchCities(String query);
  Future<int> getAirQualityIndex(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient client;
  WeatherRemoteDataSourceImpl(this.client);

  @override
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final json = await client.get(
        '${AppConstants.baseUrl}${AppConstants.currentWeatherEndpoint}',
        queryParameters: {'q': cityName},
      );
      final lat = (json['coord']?['lat'] as num?)?.toDouble() ?? 0;
      final lon = (json['coord']?['lon'] as num?)?.toDouble() ?? 0;
      final aqi = await getAirQualityIndex(lat, lon);
      return WeatherModel.fromJson(json, aqi: aqi);
    } catch (e) {
      if (e is NotFoundException) {
        // Fallback: The geocoding API might know this name (e.g., Chattogram)
        // even if the weather API does not recognize it directly via q=.
        final cities = await searchCities(cityName);
        if (cities.isNotEmpty) {
          final city = cities.first;
          return getCurrentWeatherByCoords(city.latitude, city.longitude);
        }
      }
      rethrow;
    }
  }

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async {
    final json = await client.get(
      '${AppConstants.baseUrl}${AppConstants.currentWeatherEndpoint}',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    final aqi = await getAirQualityIndex(lat, lon);
    return WeatherModel.fromJson(json, aqi: aqi);
  }

  @override
  Future<ForecastModel> getForecast(double lat, double lon) async {
    final json = await client.get(
      '${AppConstants.baseUrl}${AppConstants.forecastEndpoint}',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    return ForecastModel.fromJson(json);
  }

  @override
  Future<List<CityModel>> searchCities(String query) async {
    final list = await client.getList(
      '${AppConstants.geoUrl}${AppConstants.geoDirectEndpoint}',
      queryParameters: {'q': query, 'limit': 8},
    );
    return list
        .map((e) => CityModel.fromGeoJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getAirQualityIndex(double lat, double lon) async {
    try {
      final json = await client.get(
        '${AppConstants.baseUrl}${AppConstants.airPollutionEndpoint}',
        queryParameters: {'lat': lat, 'lon': lon},
      );
      final list = json['list'] as List<dynamic>?;
      if (list == null || list.isEmpty) return 0;
      return (list.first['main']?['aqi'] as int?) ?? 0;
    } catch (_) {
      // AQI is a bonus feature — never let it break the main weather flow.
      return 0;
    }
  }
}
