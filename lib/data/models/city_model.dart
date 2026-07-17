import '../../domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    super.id,
    required super.name,
    super.nickname,
    required super.country,
    required super.latitude,
    required super.longitude,
    super.isFavorite,
    required super.addedAt,
  });

  /// From OpenWeatherMap geocoding `/geo/1.0/direct` response.
  factory CityModel.fromGeoJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0,
      addedAt: DateTime.now(),
    );
  }

  factory CityModel.fromDbMap(Map<String, dynamic> map) {
    return CityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nickname: map['nickname'] as String?,
      country: map['country'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'nickname': nickname,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_favorite': isFavorite ? 1 : 0,
      'added_at': addedAt.millisecondsSinceEpoch,
    };
  }

  factory CityModel.fromEntity(CityEntity e) {
    return CityModel(
      id: e.id,
      name: e.name,
      nickname: e.nickname,
      country: e.country,
      latitude: e.latitude,
      longitude: e.longitude,
      isFavorite: e.isFavorite,
      addedAt: e.addedAt,
    );
  }
}
