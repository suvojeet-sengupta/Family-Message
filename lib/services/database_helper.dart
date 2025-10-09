import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/weather_model.dart';
import '../config/weather_config.dart'; // New import

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'weather_app.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE weather(
            locationName TEXT PRIMARY KEY,
            temperature REAL,
            temperatureF REAL,
            condition TEXT,
            conditionCode INTEGER,
            iconUrl TEXT,
            feelsLike REAL,
            feelsLikeF REAL,
            wind REAL,
            windDir TEXT,
            windDegree INTEGER,
            humidity INTEGER,
            uvIndex REAL,
            airQuality TEXT, -- Storing as JSON String
            pressure REAL,
            hourlyForecast TEXT,
            dailyForecast TEXT,
            timestamp INTEGER,
            vis_km REAL,
            vis_miles REAL,
            dewpoint_c REAL,
            dewpoint_f REAL,
            last_updated TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE weather ADD COLUMN hourlyForecast TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE weather ADD COLUMN uvIndex REAL');
        }
      },
    );
  }

  Future<void> insertWeather(Weather weather) async {
    final db = await database;
    await db.insert(
      'weather',
      weather.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Weather?> getWeather(String locationName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weather',
      where: 'locationName = ?',
      whereArgs: [locationName],
    );

    if (maps.isNotEmpty) {
      final weatherData = maps.first;
      final timestamp = weatherData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDurationInMillis = WeatherConfig.cacheExpiryMinutes * 60 * 1000; // 5 minutes

      if ((now - timestamp) < cacheDurationInMillis) {
        // Data is fresh, return it
        return Weather.fromDatabaseMap(weatherData);
      }
    }
    // Data is stale or doesn't exist, return null to trigger a network fetch
    return null;
  }

  Future<Weather?> getLatestWeather() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weather',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Weather.fromDatabaseMap(maps.first);
    }
    return null;
  }

  Future<void> deleteWeather(String locationName) async {
    final db = await database;
    await db.delete(
      'weather',
      where: 'locationName = ?',
      whereArgs: [locationName],
    );
  }

  Future<Weather?> getAnyWeather(String locationName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weather',
      where: 'locationName = ?',
      whereArgs: [locationName],
    );

    if (maps.isNotEmpty) {
      return Weather.fromDatabaseMap(maps.first);
    }
    return null;
  }
}