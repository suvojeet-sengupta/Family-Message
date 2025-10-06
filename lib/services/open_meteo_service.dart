import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'settings_service.dart';
import 'weather_exceptions.dart';
import 'package:logger/logger.dart';
import '../config/weather_config.dart';

class OpenMeteoService {
  final String baseUrl = 'https://api.open-meteo.com/v1';
  final String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';
  final Logger _logger = Logger();

  Future<Weather> fetchWeatherByPosition(Position position) async {
    final settings = SettingsService();
    final isFahrenheit = settings.useFahrenheit;
    final tempUnit = isFahrenheit ? 'fahrenheit' : 'celsius';

    final response = await http.get(Uri.parse(
                    '$baseUrl/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,pressure_msl,us_aqi&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,sunrise,sunset&temperature_unit=$tempUnit&timezone=auto')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _mapToWeatherModel(data, 'Current Location', isFahrenheit);
    } else {
      throw WeatherApiException(
        provider: 'Open-Meteo',
        message: 'Failed to load weather data',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    final settings = SettingsService();
    final isFahrenheit = settings.useFahrenheit;
    final tempUnit = isFahrenheit ? 'fahrenheit' : 'celsius';

    final geocodingResponse = await http.get(Uri.parse('$geocodingUrl/search?name=$city&count=1')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));
    if (geocodingResponse.statusCode == 200) {
      final geocodingData = jsonDecode(geocodingResponse.body);
      if (geocodingData['results'] != null && geocodingData['results'].isNotEmpty) {
        final lat = geocodingData['results'][0]['latitude'];
        final lon = geocodingData['results'][0]['longitude'];
        final locationName = geocodingData['results'][0]['name'];

        final response = await http.get(Uri.parse(
            '$baseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,pressure_msl,us_aqi&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,sunrise,sunset&temperature_unit=$tempUnit&timezone=auto')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return _mapToWeatherModel(data, locationName, isFahrenheit);
        } else {
          throw WeatherApiException(
            provider: 'Open-Meteo',
            message: 'Failed to load weather data',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw WeatherApiException(
          provider: 'Open-Meteo',
          message: 'City not found',
        );
      }
    } else {
      throw WeatherApiException(
        provider: 'Open-Meteo',
        message: 'Failed to geocode city',
        statusCode: geocodingResponse.statusCode,
      );
    }
  }

  Weather _mapToWeatherModel(Map<String, dynamic> data, String locationName, bool isFahrenheit) {
    final usAqi = data['current']?['us_aqi'];
    return Weather(
      locationName: locationName,
      temperature: isFahrenheit ? (data['current']['temperature_2m'] - 32) * 5 / 9 : data['current']['temperature_2m'].toDouble(),
      temperatureF: isFahrenheit ? data['current']['temperature_2m'].toDouble() : (data['current']['temperature_2m'] * 9 / 5) + 32,
      condition: _getWeatherDescription(data['current']['weather_code']),
      conditionCode: data['current']['weather_code'],
      iconUrl: _getWeatherIcon(data['current']['weather_code']),
      feelsLike: isFahrenheit ? (data['current']['apparent_temperature'] - 32) * 5 / 9 : data['current']['apparent_temperature'].toDouble(),
      feelsLikeF: isFahrenheit ? data['current']['apparent_temperature'].toDouble() : (data['current']['apparent_temperature'] * 9 / 5) + 32,
      wind: data['current']['wind_speed_10m'].toDouble(),
      humidity: data['current']['relative_humidity_2m'],
      airQuality: usAqi != null ? AirQuality(usEpaIndex: usAqi) : null,
      pressure: data['current']['pressure_msl']?.toDouble(),
      hourlyForecast: _mapToHourlyForecast(data['hourly'], isFahrenheit),
      dailyForecast: _mapToDailyForecast(data['daily'], isFahrenheit),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<HourlyForecast> _mapToHourlyForecast(Map<String, dynamic> hourlyData, bool isFahrenheit) {
    List<HourlyForecast> forecast = [];
    for (int i = 0; i < hourlyData['time'].length; i++) {
      forecast.add(HourlyForecast(
        time: hourlyData['time'][i],
        temperature: isFahrenheit ? (hourlyData['temperature_2m'][i] - 32) * 5 / 9 : hourlyData['temperature_2m'][i].toDouble(),
        temperatureF: isFahrenheit ? hourlyData['temperature_2m'][i].toDouble() : (hourlyData['temperature_2m'][i] * 9 / 5) + 32,
        iconUrl: _getWeatherIcon(hourlyData['weather_code'][i]),
      ));
    }
    return forecast;
  }

  List<DailyForecast> _mapToDailyForecast(Map<String, dynamic> dailyData, bool isFahrenheit) {
    List<DailyForecast> forecast = [];
    for (int i = 0; i < dailyData['time'].length; i++) {
      forecast.add(DailyForecast(
        date: dailyData['time'][i],
        maxTemp: isFahrenheit ? (dailyData['temperature_2m_max'][i] - 32) * 5 / 9 : dailyData['temperature_2m_max'][i].toDouble(),
        maxTempF: isFahrenheit ? dailyData['temperature_2m_max'][i].toDouble() : (dailyData['temperature_2m_max'][i] * 9 / 5) + 32,
        minTemp: isFahrenheit ? (dailyData['temperature_2m_min'][i] - 32) * 5 / 9 : dailyData['temperature_2m_min'][i].toDouble(),
        minTempF: isFahrenheit ? dailyData['temperature_2m_min'][i].toDouble() : (dailyData['temperature_2m_min'][i] * 9 / 5) + 32,
        iconUrl: _getWeatherIcon(dailyData['weather_code'][i]),
        hourlyForecast: [], // Open-Meteo doesn't provide hourly forecast per day in the same way
        totalPrecipMm: dailyData['precipitation_sum'][i].toDouble(),
        condition: _getWeatherDescription(dailyData['weather_code'][i]),
        avgHumidity: 0.0,
        maxWindKph: 0.0,
        moonPhase: '',
        sunrise: dailyData['sunrise'][i],
        sunset: dailyData['sunset'][i],
      ));
    }
    forecast.sort((a, b) => a.date.compareTo(b.date));
    return forecast;
  }

  String _getWeatherDescription(int code) {
    const descriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      56: 'Light freezing drizzle',
      57: 'Dense freezing drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      66: 'Light freezing rain',
      67: 'Heavy freezing rain',
      71: 'Slight snow fall',
      73: 'Moderate snow fall',
      75: 'Heavy snow fall',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      99: 'Thunderstorm with heavy hail',
    };
    return descriptions[code] ?? 'Unknown';
  }

  String _getWeatherIcon(int code) {
    // This is a placeholder. I need to find a good source for weather icons
    // that match the WMO codes.
    return 'https://www.weatherbit.io/static/img/icons/t01d.png';
  }
}
