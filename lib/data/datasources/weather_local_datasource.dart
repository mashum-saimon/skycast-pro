import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../database/database_helper.dart';
import '../models/weather_model.dart';
import '../models/city_model.dart';

abstract class WeatherLocalDataSource {
  // Saved cities CRUD
  Future<List<CityModel>> getSavedCities();
  Future<List<CityModel>> getFavoriteCities();
  Future<CityModel> saveCity(CityModel city);
  Future<CityModel> updateCityNickname(int id, String nickname);
  Future<bool> toggleFavorite(int id, bool isFavorite);
  Future<bool> deleteCity(int id);

  // Search history
  Future<List<String>> getSearchHistory();
  Future<bool> addSearchHistory(String query);
  Future<bool> clearSearchHistory();

  // Recently viewed
  Future<List<CityModel>> getRecentlyViewed();
  Future<bool> addRecentlyViewed(CityModel city);

  // Weather cache
  Future<WeatherModel> getCachedWeather(String cityName);
  Future<bool> cacheWeather(WeatherModel weather);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final DatabaseHelper dbHelper;
  WeatherLocalDataSourceImpl(this.dbHelper);

  // ---------------------------------------------------------------------
  // Saved Cities CRUD
  // ---------------------------------------------------------------------

  @override
  Future<List<CityModel>> getSavedCities() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableSavedCities,
      orderBy: 'added_at DESC',
    );
    return maps.map((m) => CityModel.fromDbMap(m)).toList();
  }

  @override
  Future<List<CityModel>> getFavoriteCities() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableSavedCities,
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'added_at DESC',
    );
    return maps.map((m) => CityModel.fromDbMap(m)).toList();
  }

  @override
  Future<CityModel> saveCity(CityModel city) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      AppConstants.tableSavedCities,
      city.toDbMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return CityModel.fromDbMap({...city.toDbMap(), 'id': id});
  }

  @override
  Future<CityModel> updateCityNickname(int id, String nickname) async {
    final db = await dbHelper.database;
    await db.update(
      AppConstants.tableSavedCities,
      {'nickname': nickname},
      where: 'id = ?',
      whereArgs: [id],
    );
    final maps = await db.query(
      AppConstants.tableSavedCities,
      where: 'id = ?',
      whereArgs: [id],
    );
    return CityModel.fromDbMap(maps.first);
  }

  @override
  Future<bool> toggleFavorite(int id, bool isFavorite) async {
    final db = await dbHelper.database;
    final count = await db.update(
      AppConstants.tableSavedCities,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  @override
  Future<bool> deleteCity(int id) async {
    final db = await dbHelper.database;
    final count = await db.delete(
      AppConstants.tableSavedCities,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // ---------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------

  @override
  Future<List<String>> getSearchHistory() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableSearchHistory,
      orderBy: 'searched_at DESC',
      limit: 10,
    );
    return maps.map((m) => m['query'] as String).toSet().toList();
  }

  @override
  Future<bool> addSearchHistory(String query) async {
    final db = await dbHelper.database;
    await db.insert(AppConstants.tableSearchHistory, {
      'query': query,
      'searched_at': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  @override
  Future<bool> clearSearchHistory() async {
    final db = await dbHelper.database;
    await db.delete(AppConstants.tableSearchHistory);
    return true;
  }

  // ---------------------------------------------------------------------
  // Recently viewed
  // ---------------------------------------------------------------------

  @override
  Future<List<CityModel>> getRecentlyViewed() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableRecentlyViewed,
      orderBy: 'viewed_at DESC',
      limit: 10,
    );
    return maps
        .map((m) => CityModel(
              name: m['name'] as String,
              country: m['country'] as String,
              latitude: m['latitude'] as double,
              longitude: m['longitude'] as double,
              addedAt: DateTime.fromMillisecondsSinceEpoch(
                m['viewed_at'] as int,
              ),
            ))
        .toList();
  }

  @override
  Future<bool> addRecentlyViewed(CityModel city) async {
    final db = await dbHelper.database;
    // Avoid duplicate consecutive entries for the same city.
    await db.delete(
      AppConstants.tableRecentlyViewed,
      where: 'name = ? AND country = ?',
      whereArgs: [city.name, city.country],
    );
    await db.insert(AppConstants.tableRecentlyViewed, {
      'name': city.name,
      'country': city.country,
      'latitude': city.latitude,
      'longitude': city.longitude,
      'viewed_at': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  // ---------------------------------------------------------------------
  // Weather cache (offline mode)
  // ---------------------------------------------------------------------

  @override
  Future<WeatherModel> getCachedWeather(String cityName) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      AppConstants.tableWeatherCache,
      where: 'city_name = ?',
      whereArgs: [cityName],
    );
    if (maps.isEmpty) {
      throw StateError('No cached weather for $cityName');
    }
    return WeatherModel.fromDbMap(maps.first);
  }

  @override
  Future<bool> cacheWeather(WeatherModel weather) async {
    final db = await dbHelper.database;
    await db.insert(
      AppConstants.tableWeatherCache,
      weather.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
}
