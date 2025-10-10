import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'weather_service.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Weather? _currentLocationWeather;
  Map<String, Weather> _weatherData = {};
  List<String> _savedCities = [];
  bool _isLoading = false;
  String? _error;

  Weather? get currentLocationWeather => _currentLocationWeather;
  Map<String, Weather> get weatherData => _weatherData;
  List<String> get savedCities => _savedCities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherProvider() {
    _loadSavedCities();
    fetchCurrentLocationWeather();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    _savedCities = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    notifyListeners();
    _loadCachedWeatherData();
  }

  Future<void> _loadCachedWeatherData() async {
    final cachedCurrent = await _dbHelper.getLatestWeather();
    if (cachedCurrent != null) {
      _currentLocationWeather = cachedCurrent;
      notifyListeners();
    }

    for (var city in _savedCities) {
      final cachedWeather = await _dbHelper.getAnyWeather(city);
      if (cachedWeather != null) {
        _weatherData[city] = cachedWeather;
        notifyListeners();
      }
    }
  }

  Future<void> fetchCurrentLocationWeather({bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentLocationWeather = await _weatherService.fetchWeather(force: force);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForCity(String city, {bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final weather = await _weatherService.fetchWeatherByCity(city, force: force);
      _weatherData[city] = weather;
      if (!_savedCities.contains(city)) {
        _savedCities.insert(0, city);
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList(AppConstants.recentSearchesKey, _savedCities);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll({bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await fetchCurrentLocationWeather(force: force);
      for (var city in _savedCities) {
        await fetchWeatherForCity(city, force: force);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
