import 'dart:convert';

class HourlyForecast {
  final String time;
  final double temperature;
  final double temperatureF;
  final String iconUrl;
  final double uv;
  final int chanceOfRain;
  final int chanceOfSnow;
  final double windGustKph;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.temperatureF,
    required this.iconUrl,
    required this.uv,
    required this.chanceOfRain,
    required this.chanceOfSnow,
    required this.windGustKph,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      temperature: (json['temp_c'] ?? 0.0).toDouble(),
      temperatureF: (json['temp_f'] ?? 0.0).toDouble(),
      iconUrl: 'https:${json['condition']?['icon'] ?? ''}',
      uv: (json['uv'] ?? 0.0).toDouble(),
      chanceOfRain: json['chance_of_rain'] ?? 0,
      chanceOfSnow: json['chance_of_snow'] ?? 0,
      windGustKph: (json['wind_gust_kph'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'time': time,
      'temperature': temperature,
      'temperatureF': temperatureF,
      'iconUrl': iconUrl,
      'uv': uv,
      'chanceOfRain': chanceOfRain,
      'chanceOfSnow': chanceOfSnow,
      'windGustKph': windGustKph,
    };
  }

  factory HourlyForecast.fromDatabaseMap(Map<String, dynamic> map) {
    return HourlyForecast(
      time: map['time'],
      temperature: map['temperature'],
      temperatureF: map['temperatureF'],
      iconUrl: map['iconUrl'],
      uv: map['uv'] ?? 0.0,
      chanceOfRain: map['chanceOfRain'] ?? 0,
      chanceOfSnow: map['chanceOfSnow'] ?? 0,
      windGustKph: map['windGustKph'] ?? 0.0,
    );
  }
}
