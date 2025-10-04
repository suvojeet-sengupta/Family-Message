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
            condition TEXT,
            conditionCode INTEGER,
            iconUrl TEXT,
            feelsLike REAL,
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
      final cachedWeather = Weather.fromDatabaseMap(maps.first);
      // Check if data is fresh (e.g., less than 15 minutes old)
      final fifteenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch;
      if (cachedWeather.timestamp > fifteenMinutesAgo) {
        return cachedWeather;
      } else {
        // Data is old, delete it
        await deleteWeather(locationName);
        return null;
      }
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
}
