import 'dart:convert';
import 'air_quality.dart'; // New import
import 'hourly_forecast.dart'; // New import
import 'daily_forecast.dart'; // New import

class Weather {
  final String locationName;
  final double temperature;
  final double temperatureF;
  final String condition;
  final int conditionCode;
  final String iconUrl;
  final double feelsLike;
  final double feelsLikeF;
  final double wind;
  final String windDir;
  final int windDegree;
  final int humidity;
  final AirQuality? airQuality;
  final double? pressure;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final int timestamp; // Added timestamp
  final double vis_km;
  final double vis_miles;
  final double dewpoint_c;
  final double dewpoint_f;
  final String last_updated;

  Weather({
    required this.locationName,
    required this.temperature,
    required this.temperatureF,
    required this.condition,
    required this.conditionCode,
    required this.iconUrl,
    required this.feelsLike,
    required this.feelsLikeF,
    required this.wind,
    required this.windDir,
    required this.windDegree,
    required this.humidity,
    this.airQuality,
    this.pressure,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.timestamp, // Added timestamp
    required this.vis_km,
    required this.vis_miles,
    required this.dewpoint_c,
    required this.dewpoint_f,
    required this.last_updated,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']?['name'] ?? 'Unknown',
      temperature: (json['current']?['temp_c'] ?? 0.0).toDouble(),
      temperatureF: (json['current']?['temp_f'] ?? 0.0).toDouble(),
      condition: json['current']?['condition']?['text'] ?? '',
      conditionCode: json['current']?['condition']?['code'] ?? 0,
      iconUrl: 'https:${json['current']?['condition']?['icon'] ?? ''}',
      feelsLike: (json['current']?['feelslike_c'] ?? 0.0).toDouble(),
      feelsLikeF: (json['current']?['feelslike_f'] ?? 0.0).toDouble(),
      wind: (json['current']?['wind_kph'] ?? 0.0).toDouble(),
      windDir: json['current']?['wind_dir'] ?? '',
      windDegree: json['current']?['wind_degree'] ?? 0,
      humidity: json['current']?['humidity'] ?? 0,
      airQuality: json['current']?['air_quality'] != null
          ? AirQuality.fromJson(json['current']['air_quality'])
          : null,
      pressure: (json['current']?['pressure_mb'] ?? 0.0).toDouble(),
      hourlyForecast: ((json['forecast']?['forecastday']?[0]?['hour'] ?? []) as List)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
      dailyForecast: ((json['forecast']?['forecastday'] ?? []) as List)
          .map((day) => DailyForecast.fromJson(day))
          .toList()..sort((a, b) => a.date.compareTo(b.date)),
      timestamp: DateTime.now().millisecondsSinceEpoch, // Set timestamp on creation
      vis_km: (json['current']?['vis_km'] ?? 0.0).toDouble(),
      vis_miles: (json['current']?['vis_miles'] ?? 0.0).toDouble(),
      dewpoint_c: (json['current']?['dewpoint_c'] ?? 0.0).toDouble(),
      dewpoint_f: (json['current']?['dewpoint_f'] ?? 0.0).toDouble(),
      last_updated: json['current']?['last_updated'] ?? '',
    );
  }

  // Convert a Weather object into a Map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return {
      'locationName': locationName,
      'temperature': temperature,
      'temperatureF': temperatureF,
      'condition': condition,
      'conditionCode': conditionCode,
      'iconUrl': iconUrl,
      'feelsLike': feelsLike,
      'feelsLikeF': feelsLikeF,
      'wind': wind,
      'windDir': windDir,
      'windDegree': windDegree,
      'humidity': humidity,
      'airQuality': airQuality != null ? jsonEncode(airQuality!.toDatabaseMap()) : null,
      'pressure': pressure,
      'hourlyForecast': jsonEncode(hourlyForecast.map((e) => e.toDatabaseMap()).toList()),
      'dailyForecast': jsonEncode(dailyForecast.map((e) => e.toDatabaseMap()).toList()),
      'timestamp': timestamp,
      'vis_km': vis_km,
      'vis_miles': vis_miles,
      'dewpoint_c': dewpoint_c,
      'dewpoint_f': dewpoint_f,
      'last_updated': last_updated,
    };
  }

  // Create a Weather object from a database Map
  factory Weather.fromDatabaseMap(Map<String, dynamic> map) {
    return Weather(
      locationName: map['locationName'],
      temperature: map['temperature'],
      temperatureF: map['temperatureF'],
      condition: map['condition'],
      conditionCode: map['conditionCode'],
      iconUrl: map['iconUrl'],
      feelsLike: map['feelsLike'],
      feelsLikeF: map['feelsLikeF'],
      wind: map['wind'],
      windDir: map['windDir'] ?? '',
      windDegree: map['windDegree'] ?? 0,
      humidity: map['humidity'],
      airQuality: map['airQuality'] != null
          ? AirQuality.fromDatabaseMap(jsonDecode(map['airQuality']))
          : null,
      pressure: map['pressure'],
      hourlyForecast: (jsonDecode(map['hourlyForecast']) as List)
          .map((e) => HourlyForecast.fromDatabaseMap(e))
          .toList(),
      dailyForecast: (jsonDecode(map['dailyForecast']) as List)
          .map((e) => DailyForecast.fromDatabaseMap(e))
          .toList(),
      timestamp: map['timestamp'],
      vis_km: map['vis_km'] ?? 0.0,
      vis_miles: map['vis_miles'] ?? 0.0,
      dewpoint_c: map['dewpoint_c'] ?? 0.0,
      dewpoint_f: map['dewpoint_f'] ?? 0.0,
      last_updated: map['last_updated'] ?? '',
    );
  }
}
