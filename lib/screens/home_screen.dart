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
  late Future<void> _loadCacheFuture;

  @override
  void initState() {
    super.initState();
    _loadCacheFuture = _loadCachedData();
    _loadCacheFuture.then((_) {
      _refreshStaleData();
    });

    if (widget.initialWeather != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailScreen(weather: widget.initialWeather!),
          ),
);
      });
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    final cachedCurrent = await _dbHelper.getLatestWeather();
    final Map<String, Weather> weatherData = {};

    for (var city in savedCities) {
      final cachedWeather = await _dbHelper.getAnyWeather(city);
      if (cachedWeather != null) {
        weatherData[city] = cachedWeather;
      }
    }

    if (mounted) {
      setState(() {
        _currentLocationWeather = cachedCurrent;
        _savedCities = savedCities;
        _weatherData = weatherData;
      });
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

    if (_currentLocationWeather == null || force || (now - _currentLocationWeather!.timestamp) > thirtyMinutesInMillis) {
      refreshFutures.add(_fetchWeatherForCurrentLocation());
    }

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
      rethrow;
    }
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
      body: FutureBuilder<void>(
        future: _loadCacheFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: ShimmerLoading(),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          return Column(
            children: [

              Expanded(
                child: _buildWeatherList(isFahrenheit),
              ),
            ],
          );
        },
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
      if (_savedCities.isEmpty && _currentLocationWeather == null && _isGloballyRefreshing) {
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
  
      if (_savedCities.isEmpty && _currentLocationWeather == null && !_isGloballyRefreshing) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.white54),
              SizedBox(height: 16),
              Text('Search for a city to get started', style: TextStyle(fontSize: 18, color: Colors.white54)),
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
            if (_currentLocationWeather != null) ...[
              const Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  SizedBox(width: 8),
                  Text('Current location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              WeatherCard(weather: _currentLocationWeather!, isFahrenheit: isFahrenheit),
            ],
            if (_currentLocationWeather != null && _savedCities.isNotEmpty)
              const SizedBox(height: 24),
            if (_savedCities.isNotEmpty) ...[
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
                  return const ShimmerLoading();
                }
                return WeatherCard(weather: weather, isFahrenheit: isFahrenheit);
              }).toList(),
            ],
          ],
        ),
      );
  }
}