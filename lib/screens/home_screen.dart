import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:AuroraWeather/models/weather_model.dart';
import 'package:AuroraWeather/services/weather_service.dart';
import 'package:AuroraWeather/services/database_helper.dart';
import 'package:AuroraWeather/services/settings_service.dart';
import 'package:AuroraWeather/screens/weather_detail_screen.dart';
import 'package:AuroraWeather/screens/settings_screen.dart';
import 'package:AuroraWeather/widgets/shimmer_loading.dart';
import 'package:AuroraWeather/screens/search_screen.dart';
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
  final Map<String, bool> _isRefreshing = {};

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
    _savedCities = prefs.getStringList('recentSearches') ?? [];

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
    final now = DateTime.now().millisecondsSinceEpoch;
    const thirtyMinutesInMillis = 30 * 60 * 1000;

    // Refresh current location
    if (_currentLocationWeather != null) {
      if (force || (now - _currentLocationWeather!.timestamp) > thirtyMinutesInMillis) {
        _fetchWeatherForCurrentLocation();
      }
    } else {
       _fetchWeatherForCurrentLocation();
    }

    // Refresh saved cities
    for (var city in _savedCities) {
      final weather = _weatherData[city];
      if (weather != null) {
        if (force || (now - weather.timestamp) > thirtyMinutesInMillis) {
          _fetchWeatherForCity(city);
        }
      } else {
        _fetchWeatherForCity(city);
      }
    }
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    if (_isRefreshing['current'] == true) return;
    setState(() {
      _isRefreshing['current'] = true;
    });

    try {
      final position = await _weatherService.getCurrentPosition();
      final freshCurrent = await _weatherService.fetchWeatherByPosition(position);
      setState(() {
        _currentLocationWeather = freshCurrent;
      });
    } catch (e) {
      print('Error fetching fresh current weather: $e');
    } finally {
      setState(() {
        _isRefreshing['current'] = false;
      });
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    if (_isRefreshing[city] == true) return;
    setState(() {
      _isRefreshing[city] = true;
    });

    try {
      final freshWeather = await _weatherService.fetchWeatherByCity(city);
      setState(() {
        _weatherData[city] = freshWeather;
      });
    } catch (e) {
      print('Error fetching fresh weather for $city: $e');
    } finally {
      setState(() {
        _isRefreshing[city] = false;
      });
    }
  }


  Future<void> _saveLastOpenedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenedCity', city);
  }

  Future<void> _clearLastOpenedCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastOpenedCity');
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStaleData(force: true),
          ),
        ],
      ),
      body: _buildWeatherList(isFahrenheit),
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
            WeatherCard(weather: _currentLocationWeather!, isFahrenheit: isFahrenheit, isRefreshing: _isRefreshing['current'] ?? false),
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
            return WeatherCard(weather: weather, isFahrenheit: isFahrenheit, isRefreshing: _isRefreshing[city] ?? false);
          }).toList(),
        ],
      ),
    );
  }
}
