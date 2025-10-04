import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = const String.fromEnvironment('WEATHER_API_KEY');
  final String baseUrl = 'http://api.weatherapi.com/v1';

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

    final response = await http.get(Uri.parse(
        '$baseUrl/forecast.json?key=$apiKey&q=${position.latitude},${position.longitude}&days=10'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
