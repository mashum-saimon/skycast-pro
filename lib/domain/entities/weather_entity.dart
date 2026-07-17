import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final int pressure;
  final int visibility;
  final double? uvIndex;
  final int aqi;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime timestamp;
  final int timezoneOffset;

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.pressure,
    required this.visibility,
    this.uvIndex,
    this.aqi = 0,
    required this.sunrise,
    required this.sunset,
    required this.timestamp,
    required this.timezoneOffset,
  });

  bool get isNight {
    final now = DateTime.now().toUtc().add(Duration(seconds: timezoneOffset));
    return now.isBefore(sunrise) || now.isAfter(sunset);
  }

  String get windDirection {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((windDegree % 360) / 22.5).round() % 16;
    return directions[index];
  }

  String get aqiLabel {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'N/A';
    }
  }

  @override
  List<Object?> get props => [
        cityName,
        country,
        temperature,
        condition,
        timestamp,
      ];
}
