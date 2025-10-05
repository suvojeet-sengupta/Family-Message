import 'dart:convert';

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
  final int humidity;
  final double uvIndex;
  final double? pressure;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final int timestamp; // Added timestamp

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
    required this.humidity,
    required this.uvIndex,
    this.pressure,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.timestamp, // Added timestamp
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
      humidity: json['current']?['humidity'] ?? 0,
      uvIndex: (json['current']?['uv'] ?? 0.0).toDouble(),
      pressure: (json['current']?['pressure_mb'] ?? 0.0).toDouble(),
      hourlyForecast: ((json['forecast']?['forecastday']?[0]?['hour'] ?? []) as List)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
      dailyForecast: ((json['forecast']?['forecastday'] ?? []) as List)
          .map((day) => DailyForecast.fromJson(day))
          .toList()..sort((a, b) => a.date.compareTo(b.date)),
      timestamp: DateTime.now().millisecondsSinceEpoch, // Set timestamp on creation
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
      'humidity': humidity,
      'uvIndex': uvIndex,
      'pressure': pressure,
      'hourlyForecast': jsonEncode(hourlyForecast.map((e) => e.toDatabaseMap()).toList()),
      'dailyForecast': jsonEncode(dailyForecast.map((e) => e.toDatabaseMap()).toList()),
      'timestamp': timestamp,
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
      humidity: map['humidity'],
      uvIndex: map['uvIndex'],
      pressure: map['pressure'],
      hourlyForecast: (jsonDecode(map['hourlyForecast']) as List)
          .map((e) => HourlyForecast.fromDatabaseMap(e))
          .toList(),
      dailyForecast: (jsonDecode(map['dailyForecast']) as List)
          .map((e) => DailyForecast.fromDatabaseMap(e))
          .toList(),
      timestamp: map['timestamp'],
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final double temperatureF;
  final String iconUrl;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.temperatureF,
    required this.iconUrl,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      temperature: (json['temp_c'] ?? 0.0).toDouble(),
      temperatureF: (json['temp_f'] ?? 0.0).toDouble(),
      iconUrl: 'https:${json['condition']?['icon'] ?? ''}',
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'time': time,
      'temperature': temperature,
      'temperatureF': temperatureF,
      'iconUrl': iconUrl,
    };
  }

  factory HourlyForecast.fromDatabaseMap(Map<String, dynamic> map) {
    return HourlyForecast(
      time: map['time'],
      temperature: map['temperature'],
      temperatureF: map['temperatureF'],
      iconUrl: map['iconUrl'],
    );
  }
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double maxTempF;
  final double minTemp;
  final double minTempF;
  final String iconUrl;
  final String condition; // Add this
  final List<HourlyForecast> hourlyForecast;
  final double totalPrecipMm;
  final double avgVisibilityKm;
  final double avgHumidity; // Better option than pressure
  final double maxWindKph;  // Useful data
  final String sunrise;
  final String sunset;
  final String moonPhase;  // Bonus!

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.maxTempF,
    required this.minTemp,
    required this.minTempF,
    required this.iconUrl,
    required this.condition,
    required this.hourlyForecast,
    required this.totalPrecipMm,
    required this.avgVisibilityKm,
    required this.avgHumidity,
    required this.maxWindKph,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] ?? '',
      maxTemp: (json['day']?['maxtemp_c'] ?? 0.0).toDouble(),
      maxTempF: (json['day']?['maxtemp_f'] ?? 0.0).toDouble(),
      minTemp: (json['day']?['mintemp_c'] ?? 0.0).toDouble(),
      minTempF: (json['day']?['mintemp_f'] ?? 0.0).toDouble(),
      iconUrl: 'https:${json['day']?['condition']?['icon'] ?? ''}',
      condition: json['day']?['condition']?['text'] ?? '',
      hourlyForecast: ((json['hour'] ?? []) as List)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
      totalPrecipMm: (json['day']?['totalprecip_mm'] ?? 0.0).toDouble(),
      avgVisibilityKm: (json['day']?['avgvis_km'] ?? 0.0).toDouble(),
      avgHumidity: (json['day']?['avghumidity'] ?? 0.0).toDouble(),
      maxWindKph: (json['day']?['maxwind_kph'] ?? 0.0).toDouble(),
      sunrise: json['astro']?['sunrise'] ?? '', // ✅ FIXED
      sunset: json['astro']?['sunset'] ?? '',   // ✅ FIXED
      moonPhase: json['astro']?['moon_phase'] ?? '',
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'maxTempF': maxTempF,
      'minTemp': minTemp,
      'minTempF': minTempF,
      'iconUrl': iconUrl,
      'condition': condition,
      'hourlyForecast': jsonEncode(hourlyForecast.map((e) => e.toDatabaseMap()).toList()),
      'totalPrecipMm': totalPrecipMm,
      'avgVisibilityKm': avgVisibilityKm,
      'avgHumidity': avgHumidity,
      'maxWindKph': maxWindKph,
      'sunrise': sunrise,
      'sunset': sunset,
      'moonPhase': moonPhase,
    };
  }

  factory DailyForecast.fromDatabaseMap(Map<String, dynamic> map) {
    return DailyForecast(
      date: map['date'],
      maxTemp: map['maxTemp'],
      maxTempF: map['maxTempF'],
      minTemp: map['minTemp'],
      minTempF: map['minTempF'],
      iconUrl: map['iconUrl'],
      condition: map['condition'],
      hourlyForecast: (jsonDecode(map['hourlyForecast']) as List)
          .map((e) => HourlyForecast.fromDatabaseMap(e))
          .toList(),
      totalPrecipMm: map['totalPrecipMm'],
      avgVisibilityKm: map['avgVisibilityKm'],
      avgHumidity: map['avgHumidity'],
      maxWindKph: map['maxWindKph'],
      sunrise: map['sunrise'],
      sunset: map['sunset'],
      moonPhase: map['moonPhase'],
    );
  }
}