import 'dart:convert';

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
