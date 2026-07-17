import 'package:equatable/equatable.dart';

class HourlyForecastEntity extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String icon;
  final String condition;
  final double pop; // probability of precipitation

  const HourlyForecastEntity({
    required this.dateTime,
    required this.temperature,
    required this.icon,
    required this.condition,
    required this.pop,
  });

  @override
  List<Object?> get props => [dateTime, temperature, condition];
}

class DailyForecastEntity extends Equatable {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String condition;
  final double pop;
  final int humidity;
  final double windSpeed;

  const DailyForecastEntity({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.condition,
    required this.pop,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  List<Object?> get props => [date, tempMin, tempMax, condition];
}

class ForecastEntity extends Equatable {
  final List<HourlyForecastEntity> hourly;
  final List<DailyForecastEntity> daily;

  const ForecastEntity({required this.hourly, required this.daily});

  @override
  List<Object?> get props => [hourly, daily];
}
