
import '../services/weather_exceptions.dart';

class WeatherConfig {
  static const int cacheExpiryHours = 1;
  static const int apiTimeoutSeconds = 10;
  static const int forecastDays = 10;
  static const bool includeAqi = true;

  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  // Environment variables
  static String get weatherApiKey =>
      const String.fromEnvironment('WEATHER_API_KEY');

  static String get openWeatherApiKey =>
      const String.fromEnvironment('OPEN_WEATHER_API');

  // Validation
  static void validate() {
    if (weatherApiKey.isEmpty) {
      throw ConfigurationException('WEATHER_API_KEY not set');
    }
    if (openWeatherApiKey.isEmpty) {
      throw ConfigurationException('OPEN_WEATHER_API not set');
    }
  }
}
