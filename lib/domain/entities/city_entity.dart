import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final int? id;
  final String name;
  final String? nickname;
  final String country;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final DateTime addedAt;

  const CityEntity({
    this.id,
    required this.name,
    this.nickname,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    required this.addedAt,
  });

  String get displayName => nickname?.isNotEmpty == true ? nickname! : name;

  CityEntity copyWith({
    int? id,
    String? name,
    String? nickname,
    String? country,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    DateTime? addedAt,
  }) {
    return CityEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, nickname, country, isFavorite];
}
