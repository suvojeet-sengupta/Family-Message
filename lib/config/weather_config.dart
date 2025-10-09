
import '../services/weather_exceptions.dart';

class WeatherConfig {
  static const int cacheExpiryMinutes = 5;
  static const int apiTimeoutSeconds = 10;
  static const int forecastDays = 10;
  static const bool includeAqi = true;

  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';

  // Environment variables
  static String get _weatherApiKey1 =>
      const String.fromEnvironment('WEATHER_API_KEY');
  static String get _weatherApiKey2 =>
      const String.fromEnvironment('WEATHER_API_2');

  static List<String> get weatherApiKeys {
    final keys = <String>[];
    if (_weatherApiKey1.isNotEmpty) keys.add(_weatherApiKey1);
    if (_weatherApiKey2.isNotEmpty) keys.add(_weatherApiKey2);
    return keys;
  }

  // Validation
  static void validate() {
    if (weatherApiKeys.isEmpty) {
      throw ConfigurationException('No Weather API keys found.');
    }
  }
}
