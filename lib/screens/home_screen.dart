import 'package:AuroraWeather/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/database_helper.dart';
import '../services/settings_service.dart';
import './weather_detail_screen.dart';
import './settings_screen.dart';
import '../widgets/shimmer_loading.dart';
import './search_screen.dart';
import '../widgets/weather_card.dart';

import '../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  final Weather? initialWeather;

  const HomeScreen({super.key, this.initialWeather});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _savedCities = [];
  Map<String, Weather> _weatherData = {};
  Weather? _currentLocationWeather;
  bool _isGloballyRefreshing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialWeather != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailScreen(weather: widget.initialWeather!),
          ),
        ).then((_) => _clearLastOpenedCity());
      });
    }
    _loadCachedData();
    _refreshStaleData();
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    _savedCities = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];

    final cachedCurrent = await _dbHelper.getLatestWeather();
    if (cachedCurrent != null) {
      setState(() {
        _currentLocationWeather = cachedCurrent;
      });
    }

    for (var city in _savedCities) {
      final cachedWeather = await _dbHelper.getAnyWeather(city);
      if (cachedWeather != null) {
        setState(() {
          _weatherData[city] = cachedWeather;
        });
      }
    }
  }

  Future<void> _refreshStaleData({bool force = false}) async {
    if (_isGloballyRefreshing) return;

    setState(() {
      _isGloballyRefreshing = true;
    });

    final now = DateTime.now().millisecondsSinceEpoch;
    const thirtyMinutesInMillis = 30 * 60 * 1000;
    final List<Future> refreshFutures = [];

    // Refresh current location
    if (_currentLocationWeather == null || force || (now - _currentLocationWeather!.timestamp) > thirtyMinutesInMillis) {
      refreshFutures.add(_fetchWeatherForCurrentLocation());
    }

    // Refresh saved cities
    for (var city in _savedCities) {
      final weather = _weatherData[city];
      if (weather == null || force || (now - weather.timestamp) > thirtyMinutesInMillis) {
        refreshFutures.add(_fetchWeatherForCity(city));
      }
    }

    if (refreshFutures.isNotEmpty) {
      try {
        await Future.wait(refreshFutures);
      } catch (e) {
        print('Error during refresh: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isGloballyRefreshing = false;
      });
    }
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    try {
      final position = await _weatherService.getCurrentPosition();
      final freshCurrent = await _weatherService.fetchWeatherByPosition(position);
      if (mounted) {
        setState(() {
          _currentLocationWeather = freshCurrent;
        });
      }
    } catch (e) {
      print('Error fetching fresh current weather: $e');
      // Optionally rethrow to let Future.wait catch it
      rethrow;
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    try {
      final freshWeather = await _weatherService.fetchWeatherByCity(city);
      if (mounted) {
        setState(() {
          _weatherData[city] = freshWeather;
        });
      }
    } catch (e) {
      print('Error fetching fresh weather for $city: $e');
      // Optionally rethrow to let Future.wait catch it
      rethrow;
    }
  }


  Future<void> _saveLastOpenedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.lastOpenedCityKey, city);
  }

  Future<void> _clearLastOpenedCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.lastOpenedCityKey);
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isFahrenheit = settingsService.useFahrenheit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          
        ],
      ),
      body: Column(
        children: [
          if (_isGloballyRefreshing)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black.withOpacity(0.5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text('Updating weather...'),
                ],
              ),
            ),
          Expanded(
            child: _buildWeatherList(isFahrenheit),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            if (!_savedCities.contains(newCity)) {
              setState(() {
                _savedCities.insert(0, newCity);
              });
              _fetchWeatherForCity(newCity);
            }
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildWeatherList(bool isFahrenheit) {
    if (_savedCities.isEmpty && _currentLocationWeather == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching weather...', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshStaleData(force: true),
      color: Colors.amber,
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined),
              SizedBox(width: 8),
              Text('Current location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentLocationWeather != null)
            WeatherCard(weather: _currentLocationWeather!, isFahrenheit: isFahrenheit),
          if (_currentLocationWeather == null)
            const ShimmerLoading(), // Show shimmer while initially fetching
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(Icons.bookmark_border),
              SizedBox(width: 8),
              Text('Saved locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ..._savedCities.map((city) {
            final weather = _weatherData[city];
            if (weather == null) {
              return const ShimmerLoading(); // Show shimmer for cities being fetched
            }
            return WeatherCard(weather: weather, isFahrenheit: isFahrenheit);
          }).toList(),
        ],
      ),
    );
  }
}
