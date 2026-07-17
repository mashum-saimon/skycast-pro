import 'dart:collection';
import '../../domain/entities/forecast_entity.dart';

class HourlyForecastModel extends HourlyForecastEntity {
  const HourlyForecastModel({
    required super.dateTime,
    required super.temperature,
    required super.icon,
    required super.condition,
    required super.pop,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0,
      icon: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['icon'] as String
          : '01d',
      condition: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['main'] as String
          : 'Clear',
      pop: (json['pop'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DailyForecastModel extends DailyForecastEntity {
  const DailyForecastModel({
    required super.date,
    required super.tempMin,
    required super.tempMax,
    required super.icon,
    required super.condition,
    required super.pop,
    required super.humidity,
    required super.windSpeed,
  });
}

class ForecastModel extends ForecastEntity {
  const ForecastModel({required super.hourly, required super.daily});

  /// The free `/forecast` endpoint returns 3-hour steps for 5 days.
  /// We derive an hourly list (next 24h / 8 entries) and aggregate
  /// daily min/max/condition buckets from it.
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = (json['list'] as List<dynamic>? ?? []);

    final hourly = list
        .take(8)
        .map((e) => HourlyForecastModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final Map<String, List<Map<String, dynamic>>> byDay =
        LinkedHashMap<String, List<Map<String, dynamic>>>();

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch((map['dt'] as int) * 1000);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      byDay.putIfAbsent(key, () => []).add(map);
    }

    final daily = byDay.entries.map((entry) {
      final items = entry.value;
      final temps = items
          .map((e) => (e['main']?['temp'] as num?)?.toDouble() ?? 0)
          .toList();
      final pops = items.map((e) => (e['pop'] as num?)?.toDouble() ?? 0).toList();
      final humidity = items
          .map((e) => e['main']?['humidity'] as int? ?? 0)
          .reduce((a, b) => a + b) ~/
          items.length;
      final wind = items
          .map((e) => (e['wind']?['speed'] as num?)?.toDouble() ?? 0)
          .reduce((a, b) => a + b) /
          items.length;

      // Pick the mid-day entry's icon/condition for best representativeness.
      final midIndex = items.length ~/ 2;
      final midItem = items[midIndex];
      final firstDt = DateTime.fromMillisecondsSinceEpoch(
        (items.first['dt'] as int) * 1000,
      );

      return DailyForecastModel(
        date: DateTime(firstDt.year, firstDt.month, firstDt.day),
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        icon: (midItem['weather'] as List?)?.isNotEmpty == true
            ? midItem['weather'][0]['icon'] as String
            : '01d',
        condition: (midItem['weather'] as List?)?.isNotEmpty == true
            ? midItem['weather'][0]['main'] as String
            : 'Clear',
        pop: pops.isNotEmpty ? pops.reduce((a, b) => a > b ? a : b) : 0,
        humidity: humidity,
        windSpeed: wind,
      );
    }).take(7).toList();

    return ForecastModel(hourly: hourly, daily: daily);
  }
}
