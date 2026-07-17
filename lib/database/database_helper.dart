import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';

/// Singleton wrapper around the SQLite database used for:
/// saved cities, favorites, search history, weather cache, recently viewed.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE ${AppConstants.tableUsers} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSavedCities} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nickname TEXT,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        added_at INTEGER NOT NULL,
        UNIQUE(name, country)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSearchHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        searched_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableWeatherCache} (
        city_name TEXT PRIMARY KEY,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        temperature REAL NOT NULL,
        feels_like REAL NOT NULL,
        temp_min REAL NOT NULL,
        temp_max REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        humidity INTEGER NOT NULL,
        wind_speed REAL NOT NULL,
        wind_degree INTEGER NOT NULL,
        pressure INTEGER NOT NULL,
        visibility INTEGER NOT NULL,
        aqi INTEGER NOT NULL DEFAULT 0,
        sunrise INTEGER NOT NULL,
        sunset INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        timezone_offset INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableRecentlyViewed} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        viewed_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<int> getDatabaseSizeInBytes() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<void> clearWeatherCache() async {
    final db = await database;
    await db.delete(AppConstants.tableWeatherCache);
    // Vacuum reclaims storage space after deletion
    await db.execute('VACUUM');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
