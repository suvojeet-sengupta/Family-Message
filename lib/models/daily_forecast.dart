import 'dart:convert';
import 'hourly_forecast.dart'; // New import

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
      avgHumidity: map['avgHumidity'],
      maxWindKph: map['maxWindKph'],
      sunrise: map['sunrise'],
      sunset: map['sunset'],
      moonPhase: map['moonPhase'] ?? '',
    );
  }
}
