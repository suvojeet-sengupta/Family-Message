import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import 'database_helper.dart';
import 'open_meteo_service.dart';
import 'open_weather_service.dart';

class WeatherService {
  final String weatherApiKey = const String.fromEnvironment('WEATHER_API_KEY');
  final String openWeatherApiKey = const String.fromEnvironment('OPEN_WEATHER_API');
  final String baseUrl = 'http://api.weatherapi.com/v1';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final OpenMeteoService _openMeteoService = OpenMeteoService();
  final OpenWeatherService _openWeatherService = OpenWeatherService();

  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<Weather> fetchWeather() async {
    final position = await getCurrentPosition();
    return await fetchWeatherByPosition(position);
  }

  Future<Weather> fetchWeatherByPosition(Position position) async {
    try {
      print('Attempting to fetch weather from WeatherAPI.com');
      if (weatherApiKey.isEmpty) throw Exception('WeatherAPI key not set');
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final locationName = placemarks.first.locality ?? placemarks.first.name ?? 'Unknown';
      Weather? cachedWeather = await _dbHelper.getWeather(locationName);
      if (cachedWeather != null) return cachedWeather;

      final response = await http.get(Uri.parse(
          '$baseUrl/forecast.json?key=$weatherApiKey&q=${position.latitude},${position.longitude}&days=10&aqi=yes'));

      if (response.statusCode == 200) {
        final weather = Weather.fromJson(jsonDecode(response.body));
        await _dbHelper.insertWeather(weather);
        return weather;
      } else {
        throw Exception('Failed to load weather data from WeatherAPI.com');
      }
    } catch (e) {
      print('Failed to fetch from WeatherAPI.com: $e. Trying OpenWeatherMap.');
      try {
        return await _openWeatherService.fetchWeatherByPosition(position);
      } catch (e2) {
        print('Failed to fetch from OpenWeatherMap: $e2. Using Open-Meteo as last resort.');
        return await _openMeteoService.fetchWeatherByPosition(position);
      }
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    try {
      print('Attempting to fetch weather for $city from WeatherAPI.com');
      if (weatherApiKey.isEmpty) throw Exception('WeatherAPI key not set');

      Weather? cachedWeather = await _dbHelper.getWeather(city);
      if (cachedWeather != null) return cachedWeather;

      final response = await http.get(Uri.parse(
          '$baseUrl/forecast.json?key=$weatherApiKey&q=$city&days=10&aqi=yes'));

      if (response.statusCode == 200) {
        final weather = Weather.fromJson(jsonDecode(response.body));
        await _dbHelper.insertWeather(weather);
        return weather;
      } else {
        throw Exception('Failed to load weather data for $city from WeatherAPI.com');
      }
    } catch (e) {
      print('Failed to fetch from WeatherAPI.com: $e. Trying OpenWeatherMap.');
      try {
        return await _openWeatherService.fetchWeatherByCity(city);
      } catch (e2) {
        print('Failed to fetch from OpenWeatherMap: $e2. Using Open-Meteo as last resort.');
        return await _openMeteoService.fetchWeatherByCity(city);
      }
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (weatherApiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not set. Please provide it using --dart-define.');
    }

    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse(
        '$baseUrl/search.json?key=$weatherApiKey&q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['name'] as String).toList();
    } else {
      throw Exception('Failed to search for cities');
    }
  }
}