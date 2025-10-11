import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'weather_service.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'weather_exceptions.dart';

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

  void clearError() {
    _error = null;
  }

  WeatherProvider() {
    _loadSavedCities();
    fetchCurrentLocationWeather();
  }

  String _getErrorMessage(Object e) {
    if (e is LocationPermissionDeniedException) {
      return 'Location permission denied. Please enable it in settings to see local weather.';
    }
    if (e is NoInternetException) {
      return 'No internet connection. Please check your connection and try again.';
    }
    if (e is WeatherApiException) {
      return 'Could not get weather data from the service. Please try again later.';
    }
    if (e.toString().contains('Could not determine location')) {
      return 'Could not determine your location. Please check your GPS and try again.';
    }
    return 'An unexpected error occurred. Please try again.';
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
      final newWeather = await _weatherService.fetchWeather(force: force);
      _currentLocationWeather = newWeather;

      // Sync with saved locations
      if (_weatherData.containsKey(newWeather.locationName)) {
        _weatherData[newWeather.locationName] = newWeather;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
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
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reorderSavedCities(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = _savedCities.removeAt(oldIndex);
    _savedCities.insert(newIndex, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.recentSearchesKey, _savedCities);
    notifyListeners();
  }

  Future<void> removeCity(String city) async {
    _savedCities.remove(city);
    _weatherData.remove(city);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.recentSearchesKey, _savedCities);
    
    await _dbHelper.deleteWeather(city);
    
    notifyListeners();
  }

  Future<void> refreshAll({bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Future> futures = [];
      bool hasError = false;

      // Add future for current location weather
      futures.add(
        _weatherService.fetchWeather(force: force).then((weather) {
          _currentLocationWeather = weather;
        }).catchError((e) {
          // Handle error for this specific fetch if needed
          print('Error fetching current location weather: $e');
          if (!hasError) {
            _error = _getErrorMessage(e);
            hasError = true;
          }
        })
      );

      // Add futures for all saved cities
      for (var city in _savedCities) {
        futures.add(
          _weatherService.fetchWeatherByCity(city, force: force).then((weather) {
            _weatherData[city] = weather;
          }).catchError((e) {
            // Handle error for this specific fetch if needed
            print('Error fetching weather for $city: $e');
            if (!hasError) { // Only set the first error
              _error = _getErrorMessage(e);
              hasError = true;
            }
          })
        );
      }

      // Wait for all futures to complete
      await Future.wait(futures);

    } catch (e) {
      if (_error == null) _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
