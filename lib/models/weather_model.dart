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
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.timestamp, // Added timestamp
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']['name'],
      temperature: json['current']['temp_c'],
      temperatureF: json['current']['temp_f'],
      condition: json['current']['condition']['text'],
      conditionCode: json['current']['condition']['code'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
      feelsLike: json['current']['feelslike_c'],
      feelsLikeF: json['current']['feelslike_f'],
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
      'temperatureF': temperatureF,
      'condition': condition,
      'conditionCode': conditionCode,
      'iconUrl': iconUrl,
      'feelsLike': feelsLike,
      'feelsLikeF': feelsLikeF,
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
      temperatureF: map['temperatureF'],
      condition: map['condition'],
      conditionCode: map['conditionCode'],
      iconUrl: map['iconUrl'],
      feelsLike: map['feelsLike'],
      feelsLikeF: map['feelsLikeF'],
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
      time: json['time'],
      temperature: json['temp_c'],
      temperatureF: json['temp_f'],
      iconUrl: 'https:${json['condition']['icon']}',
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
  final List<HourlyForecast> hourlyForecast;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.maxTempF,
    required this.minTemp,
    required this.minTempF,
    required this.iconUrl,
    required this.hourlyForecast,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      maxTempF: json['day']['maxtemp_f'],
      minTemp: json['day']['mintemp_c'],
      minTempF: json['day']['mintemp_f'],
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
      'maxTempF': maxTempF,
      'minTemp': minTemp,
      'minTempF': minTempF,
      'iconUrl': iconUrl,
      'hourlyForecast':
          jsonEncode(hourlyForecast.map((e) => e.toDatabaseMap()).toList()),
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
      hourlyForecast: (jsonDecode(map['hourlyForecast']) as List)
          .map((e) => HourlyForecast.fromDatabaseMap(e))
          .toList(),
    );
  }
}