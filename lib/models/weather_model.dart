import 'dart:convert';

class Weather {
  final String locationName;
  final double temperature;
  final String condition;
  final int conditionCode;
  final String iconUrl;
  final double feelsLike;
  final double wind;
  final int humidity;
  final double uvIndex;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final int timestamp; // Added timestamp

  Weather({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.conditionCode,
    required this.iconUrl,
    required this.feelsLike,
    required this.wind,
    required this.humidity,
    required this.uvIndex,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.timestamp, // Added timestamp
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']['name'],
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
      conditionCode: json['current']['condition']['code'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
      feelsLike: json['current']['feelslike_c'],
      wind: json['current']['wind_kph'],
      humidity: json['current']['humidity'],
      uvIndex: json['current']['uv'],
      hourlyForecast: (json['forecast']['forecastday'][0]['hour'] as List)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
      dailyForecast: (json['forecast']['forecastday'] as List)
          .map((day) => DailyForecast.fromJson(day))
          .toList(),
      timestamp: DateTime.now().millisecondsSinceEpoch, // Set timestamp on creation
    );
  }

  // Convert a Weather object into a Map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return {
      'locationName': locationName,
      'temperature': temperature,
      'condition': condition,
      'conditionCode': conditionCode,
      'iconUrl': iconUrl,
      'feelsLike': feelsLike,
      'wind': wind,
      'humidity': humidity,
      'uvIndex': uvIndex,
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
      condition: map['condition'],
      conditionCode: map['conditionCode'],
      iconUrl: map['iconUrl'],
      feelsLike: map['feelsLike'],
      wind: map['wind'],
      humidity: map['humidity'],
      uvIndex: map['uvIndex'],
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
  final String iconUrl;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.iconUrl,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'],
      temperature: json['temp_c'],
      iconUrl: 'https:${json['condition']['icon']}',
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'time': time,
      'temperature': temperature,
      'iconUrl': iconUrl,
    };
  }

  factory HourlyForecast.fromDatabaseMap(Map<String, dynamic> map) {
    return HourlyForecast(
      time: map['time'],
      temperature: map['temperature'],
      iconUrl: map['iconUrl'],
    );
  }
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String iconUrl;
  final List<HourlyForecast> hourlyForecast;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.iconUrl,
    required this.hourlyForecast,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      iconUrl: 'https:${json['day']['condition']['icon']}',
      hourlyForecast: (json['hour'] as List)
          .map((hour) => HourlyForecast.fromJson(hour))
          .toList(),
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'iconUrl': iconUrl,
      'hourlyForecast':
          jsonEncode(hourlyForecast.map((e) => e.toDatabaseMap()).toList()),
    };
  }

  factory DailyForecast.fromDatabaseMap(Map<String, dynamic> map) {
    return DailyForecast(
      date: map['date'],
      maxTemp: map['maxTemp'],
      minTemp: map['minTemp'],
      iconUrl: map['iconUrl'],
      hourlyForecast: (jsonDecode(map['hourlyForecast']) as List)
          .map((e) => HourlyForecast.fromDatabaseMap(e))
          .toList(),
    );
  }
}