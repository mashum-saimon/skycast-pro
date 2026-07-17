import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.condition,
    required super.description,
    required super.icon,
    required super.humidity,
    required super.windSpeed,
    required super.windDegree,
    required super.pressure,
    required super.visibility,
    super.uvIndex,
    super.aqi,
    required super.sunrise,
    required super.sunset,
    required super.timestamp,
    required super.timezoneOffset,
  });

  /// Builds a [WeatherModel] from an OpenWeatherMap `/weather` response.
  factory WeatherModel.fromJson(Map<String, dynamic> json, {int aqi = 0}) {
    final tzOffset = json['timezone'] as int? ?? 0;
    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      country: (json['sys']?['country'] as String?) ?? '',
      latitude: (json['coord']?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['coord']?['lon'] as num?)?.toDouble() ?? 0,
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0,
      tempMin: (json['main']?['temp_min'] as num?)?.toDouble() ?? 0,
      tempMax: (json['main']?['temp_max'] as num?)?.toDouble() ?? 0,
      condition: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['main'] as String
          : 'Clear',
      description: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['description'] as String
          : '',
      icon: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['icon'] as String
          : '01d',
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0,
      windDegree: json['wind']?['deg'] as int? ?? 0,
      pressure: json['main']?['pressure'] as int? ?? 0,
      visibility: json['visibility'] as int? ?? 10000,
      aqi: aqi,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((json['sys']?['sunrise'] as int? ?? 0) * 1000),
        isUtc: true,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((json['sys']?['sunset'] as int? ?? 0) * 1000),
        isUtc: true,
      ),
      timestamp: DateTime.now(),
      timezoneOffset: tzOffset,
    );
  }

  /// Maps a SQLite row back into a [WeatherModel] (for offline cache).
  factory WeatherModel.fromDbMap(Map<String, dynamic> map) {
    return WeatherModel(
      cityName: map['city_name'] as String,
      country: map['country'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      temperature: map['temperature'] as double,
      feelsLike: map['feels_like'] as double,
      tempMin: map['temp_min'] as double,
      tempMax: map['temp_max'] as double,
      condition: map['condition'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      humidity: map['humidity'] as int,
      windSpeed: map['wind_speed'] as double,
      windDegree: map['wind_degree'] as int,
      pressure: map['pressure'] as int,
      visibility: map['visibility'] as int,
      aqi: map['aqi'] as int? ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(map['sunrise'] as int),
      sunset: DateTime.fromMillisecondsSinceEpoch(map['sunset'] as int),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      timezoneOffset: map['timezone_offset'] as int,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'city_name': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'condition': condition,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'wind_degree': windDegree,
      'pressure': pressure,
      'visibility': visibility,
      'aqi': aqi,
      'sunrise': sunrise.millisecondsSinceEpoch,
      'sunset': sunset.millisecondsSinceEpoch,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timezone_offset': timezoneOffset,
    };
  }
}
