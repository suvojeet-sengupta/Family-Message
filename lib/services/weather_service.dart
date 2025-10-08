
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import '../models/cache_key.dart';
import 'database_helper.dart';
import 'weather_exceptions.dart';
import 'package:logger/logger.dart';
import '../models/search_result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/weather_config.dart';

class WeatherService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  WeatherService() {
    WeatherConfig.validate();
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Weather> fetchWeather() async {
    final position = await getCurrentPosition();
    return await _fetchWeatherData(position: position);
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    return await _fetchWeatherData(city: city);
  }

  Future<Weather> fetchWeatherByPosition(Position position) async {
    return await _fetchWeatherData(position: position);
  }

  Future<Weather> _fetchWeatherData({String? city, Position? position}) async {
    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      _logger.w('No internet connection. Returning cached data.');
      final cacheKey = city ?? (await _getCacheKeyFromPosition(position!));
      final cachedWeather = await _dbHelper.getAnyWeather(cacheKey);
      if (cachedWeather != null) {
        return cachedWeather;
      }
      throw NoInternetException('No internet connection and no cached data available.');
    }

    final cacheKey = city != null ? CacheKey.fromCity(city, null).toString() : (await _getCacheKeyFromPosition(position!));
    final cachedWeather = await _dbHelper.getWeather(cacheKey);
    if (cachedWeather != null) {
      _logger.d('Returning fresh cached weather for $cacheKey');
      return cachedWeather;
    }

    // Only fetch from WeatherAPI
    try {
      return await _fetchWithRetry(() => _fetchFromWeatherApi(city: city, position: position));
    } catch (e, stackTrace) {
      _logger.e('WeatherAPI.com failed after retries', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String> _getCacheKeyFromPosition(Position position) async {
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      return CacheKey.fromCity(placemarks.first.locality ?? placemarks.first.name ?? 'Unknown', placemarks.first.country).toString();
    }
    return CacheKey.fromCoordinates(position.latitude, position.longitude).toString();
  }

  Future<Weather> _fetchFromWeatherApi({String? city, Position? position}) async {
    if (WeatherConfig.weatherApiKey.isEmpty) {
      throw ConfigurationException('WEATHER_API_KEY is not set.');
    }

    String url;
    if (city != null) {
      url = '${WeatherConfig.weatherApiBaseUrl}/forecast.json?key=${WeatherConfig.weatherApiKey}&q=$city&days=${WeatherConfig.forecastDays}&aqi=${WeatherConfig.includeAqi ? 'yes' : 'no'}';
    } else if (position != null) {
      url = '${WeatherConfig.weatherApiBaseUrl}/forecast.json?key=${WeatherConfig.weatherApiKey}&q=${position.latitude},${position.longitude}&days=${WeatherConfig.forecastDays}&aqi=${WeatherConfig.includeAqi ? 'yes' : 'no'}';
    } else {
      throw ArgumentError('Either city or position must be provided.');
    }

    final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (!jsonData.containsKey('location') || !jsonData.containsKey('current')) {
        throw ParseException('Invalid API response format from WeatherAPI.com');
      }
      final weather = Weather.fromJson(jsonData);
      await _dbHelper.insertWeather(weather);
      return weather;
    } else {
      throw WeatherApiException(
        provider: 'WeatherAPI.com',
        message: 'Failed to fetch weather',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<SearchResult>> searchCities(String query) async {
    if (WeatherConfig.weatherApiKey.isEmpty) {
      throw ConfigurationException('WEATHER_API_KEY is not set. Please provide it using --dart-define.');
    }

    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse(
        '${WeatherConfig.weatherApiBaseUrl}/search.json?key=${WeatherConfig.weatherApiKey}&q=$query')).timeout(Duration(seconds: WeatherConfig.apiTimeoutSeconds));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SearchResult.fromJson(e)).toList();
    } else {
      throw WeatherApiException(
        provider: 'WeatherAPI.com',
        message: 'Failed to search for cities',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Weather> _fetchWithRetry(
    Future<Weather> Function() fetchFunction, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await fetchFunction();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        _logger.w('Attempt $attempt failed, retrying in ${retryDelay.inSeconds}s...');
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('All retry attempts failed');
  }
}
