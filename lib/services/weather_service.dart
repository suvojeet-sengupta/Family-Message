import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import 'database_helper.dart'; // Import the database helper

class WeatherService {
  final String apiKey = const String.fromEnvironment('WEATHER_API_KEY');
  final String baseUrl = 'http://api.weatherapi.com/v1';
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instantiate the database helper

  Future<Weather> fetchWeather() async {
    if (apiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not set. Please provide it using --dart-define.');
    }

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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Try to get cached data first
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final locationName = placemarks.first.locality ?? placemarks.first.name ?? 'Unknown';
    Weather? cachedWeather = await _dbHelper.getWeather(locationName);
    if (cachedWeather != null) {
      return cachedWeather;
    }

    final response = await http.get(Uri.parse(
        '$baseUrl/forecast.json?key=$apiKey&q=${position.latitude},${position.longitude}&days=10'));

    if (response.statusCode == 200) {
      final weather = Weather.fromJson(jsonDecode(response.body));
      await _dbHelper.insertWeather(weather); // Cache the new data
      return weather;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    if (apiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not set. Please provide it using --dart-define.');
    }

    // Try to get cached data first
    Weather? cachedWeather = await _dbHelper.getWeather(city);
    if (cachedWeather != null) {
      return cachedWeather;
    }

    final response = await http.get(Uri.parse(
        '$baseUrl/forecast.json?key=$apiKey&q=$city&days=10'));

    if (response.statusCode == 200) {
      final weather = Weather.fromJson(jsonDecode(response.body));
      await _dbHelper.insertWeather(weather); // Cache the new data
      return weather;
    } else {
      throw Exception('Failed to load weather data for $city');
    }
  }
}
