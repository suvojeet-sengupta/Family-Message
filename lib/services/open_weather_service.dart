import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class OpenWeatherService {
  final String apiKey = const String.fromEnvironment('OPEN_WEATHER_API');
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> fetchWeatherByPosition(Position position) async {
    if (apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API key is not set.');
    }

    final weatherResponse = await http.get(Uri.parse(
        '$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric'));
    final forecastResponse = await http.get(Uri.parse(
        '$baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric'));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      return _mapToWeatherModel(weatherData, forecastData);
    } else {
      throw Exception('Failed to load weather data from OpenWeatherMap');
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    if (apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API key is not set.');
    }

    final weatherResponse = await http.get(Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'));
    final forecastResponse = await http.get(Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric'));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      return _mapToWeatherModel(weatherData, forecastData);
    } else {
      throw Exception('Failed to load weather data from OpenWeatherMap for $city');
    }
  }

  Weather _mapToWeatherModel(Map<String, dynamic> weatherData, Map<String, dynamic> forecastData) {
    return Weather(
      locationName: weatherData['name'],
      temperature: weatherData['main']['temp'].toDouble(),
      condition: weatherData['weather'][0]['description'],
      conditionCode: weatherData['weather'][0]['id'],
      iconUrl: 'http://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png',
      feelsLike: weatherData['main']['feels_like'].toDouble(),
      wind: weatherData['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
      humidity: weatherData['main']['humidity'],
      uvIndex: 0.0, // Not available in free tier
      hourlyForecast: _mapToHourlyForecast(forecastData['list']),
      dailyForecast: _mapToDailyForecast(forecastData['list']),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<HourlyForecast> _mapToHourlyForecast(List<dynamic> forecastList) {
    return forecastList.map((item) {
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toIso8601String(),
        temperature: item['main']['temp'].toDouble(),
        iconUrl: 'http://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
      );
    }).toList();
  }

  List<DailyForecast> _mapToDailyForecast(List<dynamic> forecastList) {
    Map<String, DailyForecast> dailyForecasts = {};

    for (var item in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateString = '${date.year}-${date.month}-${date.day}';

      if (!dailyForecasts.containsKey(dateString)) {
        dailyForecasts[dateString] = DailyForecast(
          date: date.toIso8601String(),
          maxTemp: item['main']['temp_max'].toDouble(),
          minTemp: item['main']['temp_min'].toDouble(),
          iconUrl: 'http://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
          hourlyForecast: [], // Simplified for now
        );
      }
    }

    return dailyForecasts.values.toList();
  }
}
