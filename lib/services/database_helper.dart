import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/weather_model.dart';

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
      version: 1,
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
            humidity INTEGER,
            uvIndex REAL,
            hourlyForecast TEXT,
            dailyForecast TEXT,
            timestamp INTEGER
          )
        ''');
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
      final oneHourInMillis = 30 * 60 * 1000; // 30 minutes

      if ((now - timestamp) < oneHourInMillis) {
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
