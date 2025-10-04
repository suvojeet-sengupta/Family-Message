class Weather {
  final String locationName;
  final double temperature;
  final String condition;
  final String iconUrl;
  final double feelsLike;
  final double wind;
  final int humidity;
  final double uvIndex;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  Weather({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.feelsLike,
    required this.wind,
    required this.humidity,
    required this.uvIndex,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      locationName: json['location']['name'],
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
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
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String iconUrl;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.iconUrl,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      iconUrl: 'https:${json['day']['condition']['icon']}',
    );
  }
}