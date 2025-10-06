import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'settings_service.dart';
import 'weather_exceptions.dart';
import 'package:logger/logger.dart';
import '../config/weather_config.dart';

class OpenWeatherService {
  final Logger _logger = Logger();

  Future<Weather> fetchWeatherByPosition(Position position) async {
    if (WeatherConfig.openWeatherApiKey.isEmpty) {
      throw ConfigurationException('OPEN_WEATHER_API key is not set.');
    }

    final settings = SettingsService();
    final isFahrenheit = settings.useFahrenheit;
    final units = isFahrenheit ? 'imperial' : 'metric';

    final weatherResponse = await http.get(Uri.parse(
        '${WeatherConfig.openWeatherBaseUrl}/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${WeatherConfig.openWeatherApiKey}&units=$units')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));
    final forecastResponse = await http.get(Uri.parse(
        '${WeatherConfig.openWeatherBaseUrl}/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=${WeatherConfig.openWeatherApiKey}&units=$units')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));
    final airPollutionResponse = await http.get(Uri.parse(
        '${WeatherConfig.openWeatherBaseUrl}/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=${WeatherConfig.openWeatherApiKey}')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200 && airPollutionResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      final airPollutionData = jsonDecode(airPollutionResponse.body);
      return _mapToWeatherModel(weatherData, forecastData, airPollutionData, isFahrenheit);
    } else {
      throw WeatherApiException(
        provider: 'OpenWeatherMap',
        message: 'Failed to load weather data',
        statusCode: weatherResponse.statusCode, // Or combine status codes
      );
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    if (WeatherConfig.openWeatherApiKey.isEmpty) {
      throw ConfigurationException('OPEN_WEATHER_API key is not set.');
    }

    final settings = SettingsService();
    final isFahrenheit = settings.useFahrenheit;
    final units = isFahrenheit ? 'imperial' : 'metric';

    final weatherResponse = await http.get(Uri.parse('${WeatherConfig.openWeatherBaseUrl}/weather?q=$city&appid=${WeatherConfig.openWeatherApiKey}&units=$units')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));
    final forecastResponse = await http.get(Uri.parse('${WeatherConfig.openWeatherBaseUrl}/forecast?q=$city&appid=${WeatherConfig.openWeatherApiKey}&units=$units')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

    if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final forecastData = jsonDecode(forecastResponse.body);
      final lat = weatherData['coord']['lat'];
      final lon = weatherData['coord']['lon'];
      final airPollutionResponse = await http.get(Uri.parse('${WeatherConfig.openWeatherBaseUrl}/air_pollution?lat=$lat&lon=$lon&appid=${WeatherConfig.openWeatherApiKey}')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

      if (airPollutionResponse.statusCode == 200) {
        final airPollutionData = jsonDecode(airPollutionResponse.body);
        return _mapToWeatherModel(weatherData, forecastData, airPollutionData, isFahrenheit);
      } else {
        throw WeatherApiException(
          provider: 'OpenWeatherMap',
          message: 'Failed to load air pollution data for $city',
          statusCode: airPollutionResponse.statusCode,
        );
      }
    } else {
      throw WeatherApiException(
        provider: 'OpenWeatherMap',
        message: 'Failed to load weather data for $city',
        statusCode: weatherResponse.statusCode,
      );
    }
  }

  Weather _mapToWeatherModel(Map<String, dynamic> weatherData, Map<String, dynamic> forecastData, Map<String, dynamic> airPollutionData, bool isFahrenheit) {
    final aqi = airPollutionData['list'][0]['main']['aqi'];
    return Weather(
      locationName: weatherData['name'],
      temperature: isFahrenheit ? (weatherData['main']['temp'] - 32) * 5 / 9 : weatherData['main']['temp'].toDouble(),
      temperatureF: isFahrenheit ? weatherData['main']['temp'].toDouble() : (weatherData['main']['temp'] * 9 / 5) + 32,
      condition: weatherData['weather'][0]['description'],
      conditionCode: weatherData['weather'][0]['id'],
      iconUrl: 'https://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png',
      feelsLike: isFahrenheit ? (weatherData['main']['feels_like'] - 32) * 5 / 9 : weatherData['main']['feels_like'].toDouble(),
      feelsLikeF: isFahrenheit ? weatherData['main']['feels_like'].toDouble() : (weatherData['main']['feels_like'] * 9 / 5) + 32,
      wind: weatherData['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
      humidity: weatherData['main']['humidity'],
      airQuality: aqi != null ? AirQuality(usEpaIndex: _convertOwmAqiToEpaAqi(aqi)) : null,
      pressure: weatherData['main']['pressure']?.toDouble(),
      hourlyForecast: _mapToHourlyForecast(forecastData['list'], isFahrenheit),
      dailyForecast: _mapToDailyForecast(forecastData['list'], isFahrenheit, weatherData['sys']),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  num _convertOwmAqiToEpaAqi(dynamic aqi) {
    if (aqi == null) return 0;
    final aqiValue = aqi as int;
    switch (aqiValue) {
      case 1:
        return 25; // Good
      case 2:
        return 75; // Fair
      case 3:
        return 125; // Moderate
      case 4:
        return 175; // Poor
      case 5:
        return 250; // Very Poor
      default:
        return 0;
    }
  }

  List<HourlyForecast> _mapToHourlyForecast(List<dynamic> forecastList, bool isFahrenheit) {
    return forecastList.map((item) {
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toIso8601String(),
        temperature: isFahrenheit ? (item['main']['temp'] - 32) * 5 / 9 : item['main']['temp'].toDouble(),
        temperatureF: isFahrenheit ? item['main']['temp'].toDouble() : (item['main']['temp'] * 9 / 5) + 32,
        iconUrl: 'https://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
      );
    }).toList();
  }

  List<DailyForecast> _mapToDailyForecast(List<dynamic> forecastList, bool isFahrenheit, Map<String, dynamic>? sys) {
    Map<String, Map<String, dynamic>> dailyData = {};

    for (var item in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyData.containsKey(dateString)) {
        dailyData[dateString] = {
          'maxTemp': item['main']['temp_max'],
          'minTemp': item['main']['temp_min'],
          'totalPrecipMm': item['rain']?['3h'] ?? 0.0,
          'humidity': item['main']['humidity'],
          'windSpeed': item['wind']['speed'],
          'description': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        };
      } else {
        dailyData[dateString]!['maxTemp'] = (item['main']['temp_max'] > dailyData[dateString]!['maxTemp']) ? item['main']['temp_max'] : dailyData[dateString]!['maxTemp'];
        dailyData[dateString]!['minTemp'] = (item['main']['temp_min'] < dailyData[dateString]!['minTemp']) ? item['main']['temp_min'] : dailyData[dateString]!['minTemp'];
        dailyData[dateString]!['totalPrecipMm'] += item['rain']?['3h'] ?? 0.0;
      }
    }

    final today = DateTime.now();
    List<DailyForecast> dailyForecasts = [];

    dailyData.forEach((dateString, data) {
      String sunrise = '';
      String sunset = '';
      final date = DateTime.parse(dateString);

      if (sys != null && date.day == today.day && date.month == today.month && date.year == today.year) {
        sunrise = DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000).toIso8601String();
        sunset = DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000).toIso8601String();
      }

      dailyForecasts.add(DailyForecast(
        date: date.toIso8601String(),
        maxTemp: isFahrenheit ? (data['maxTemp'] - 32) * 5 / 9 : data['maxTemp'].toDouble(),
        maxTempF: isFahrenheit ? data['maxTemp'].toDouble() : (data['maxTemp'] * 9 / 5) + 32,
        minTemp: isFahrenheit ? (data['minTemp'] - 32) * 5 / 9 : data['minTemp'].toDouble(),
        minTempF: isFahrenheit ? data['minTemp'].toDouble() : (data['minTemp'] * 9 / 5) + 32,
        iconUrl: 'https://openweathermap.org/img/wn/${data['icon']}@2x.png',
        condition: data['description'],
        hourlyForecast: [], // Simplified for now
        totalPrecipMm: data['totalPrecipMm'].toDouble(),
        avgHumidity: data['humidity'].toDouble(),
        maxWindKph: (data['windSpeed'] as num).toDouble() * 3.6, // Convert m/s to km/h
        sunrise: sunrise,
        sunset: sunset,
        moonPhase: '', // Not available
      ));
    });

    dailyForecasts.sort((a, b) => a.date.compareTo(b.date));
    return dailyForecasts;
  }
}
