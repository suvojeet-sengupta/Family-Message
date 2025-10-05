import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'settings_service.dart';

class OpenWeatherService {
  final String apiKey = const String.fromEnvironment('OPEN_WEATHER_API');
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> fetchWeatherByPosition(Position position) async {
    if (apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API key is not set.');
    }

    final settings = SettingsService();
    final isFahrenheit = await settings.isFahrenheit();
    final units = isFahrenheit ? 'imperial' : 'metric';

    final weatherResponse = await http.get(Uri.parse(
        '$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=$units'));
    final forecastResponse = await http.get(Uri.parse(
        '$baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=$units'));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      return _mapToWeatherModel(weatherData, forecastData, isFahrenheit);
    } else {
      throw Exception('Failed to load weather data from OpenWeatherMap');
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    if (apiKey.isEmpty) {
      throw Exception('OPEN_WEATHER_API key is not set.');
    }

    final settings = SettingsService();
    final isFahrenheit = await settings.isFahrenheit();
    final units = isFahrenheit ? 'imperial' : 'metric';

    final weatherResponse = await http.get(Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=$units'));
    final forecastResponse = await http.get(Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=$units'));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      return _mapToWeatherModel(weatherData, forecastData, isFahrenheit);
    } else {
      throw Exception('Failed to load weather data from OpenWeatherMap for $city');
    }
  }

  Weather _mapToWeatherModel(Map<String, dynamic> weatherData, Map<String, dynamic> forecastData, bool isFahrenheit) {
    return Weather(
      locationName: weatherData['name'],
      temperature: isFahrenheit ? (weatherData['main']['temp'] - 32) * 5 / 9 : weatherData['main']['temp'].toDouble(),
      temperatureF: isFahrenheit ? weatherData['main']['temp'].toDouble() : (weatherData['main']['temp'] * 9 / 5) + 32,
      condition: weatherData['weather'][0]['description'],
      conditionCode: weatherData['weather'][0]['id'],
      iconUrl: 'http://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png',
      feelsLike: isFahrenheit ? (weatherData['main']['feels_like'] - 32) * 5 / 9 : weatherData['main']['feels_like'].toDouble(),
      feelsLikeF: isFahrenheit ? weatherData['main']['feels_like'].toDouble() : (weatherData['main']['feels_like'] * 9 / 5) + 32,
      wind: weatherData['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
      humidity: weatherData['main']['humidity'],
      uvIndex: 0.0, // Not available in free tier
      hourlyForecast: _mapToHourlyForecast(forecastData['list'], isFahrenheit),
      dailyForecast: _mapToDailyForecast(forecastData['list'], isFahrenheit),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<HourlyForecast> _mapToHourlyForecast(List<dynamic> forecastList, bool isFahrenheit) {
    return forecastList.map((item) {
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toIso8601String(),
        temperature: isFahrenheit ? (item['main']['temp'] - 32) * 5 / 9 : item['main']['temp'].toDouble(),
        temperatureF: isFahrenheit ? item['main']['temp'].toDouble() : (item['main']['temp'] * 9 / 5) + 32,
        iconUrl: 'http://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
      );
    }).toList();
  }

  List<DailyForecast> _mapToDailyForecast(List<dynamic> forecastList, bool isFahrenheit) {
    Map<String, DailyForecast> dailyForecasts = {};

    for (var item in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateString = '${date.year}-${date.month}-${date.day}';

      if (!dailyForecasts.containsKey(dateString)) {
        final humidity = item['main']['humidity'].toDouble();

        dailyForecasts[dateString] = DailyForecast(
          date: date.toIso8601String(),
          maxTemp: isFahrenheit ? (item['main']['temp_max'] - 32) * 5 / 9 : item['main']['temp_max'].toDouble(),
          maxTempF: isFahrenheit ? item['main']['temp_max'].toDouble() : (item['main']['temp_max'] * 9 / 5) + 32,
          minTemp: isFahrenheit ? (item['main']['temp_min'] - 32) * 5 / 9 : item['main']['temp_min'].toDouble(),
          minTempF: isFahrenheit ? item['main']['temp_min'].toDouble() : (item['main']['temp_min'] * 9 / 5) + 32,
          iconUrl: 'http://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
          condition: item['weather'][0]['description'],
          hourlyForecast: [], // Simplified for now
          totalPrecipMm: 0.0,
          avgVisibilityKm: 10.0,
          avgHumidity: humidity,
          maxWindKph: (item['wind']['speed'] as num).toDouble() * 3.6, // Convert m/s to km/h
          sunrise: '',
          sunset: '',
          moonPhase: '',
        );
      }
    }

    return dailyForecasts.values.toList();
  }
}
