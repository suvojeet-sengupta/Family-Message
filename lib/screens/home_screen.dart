import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'search_screen.dart';
import 'weather_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';

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
  bool _isLoading = true;
  String _loadingMessage = 'Initializing...';

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
    _loadAndRefreshData();
  }

  Future<void> _loadAndRefreshData() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Loading saved locations...';
    });

    // --- Step 1: Load all available data from cache ---
    final prefs = await SharedPreferences.getInstance();
    _savedCities = prefs.getStringList('recentSearches') ?? [];

    try {
      final cachedCurrent = await _dbHelper.getLatestWeather();
      if (cachedCurrent != null) {
        setState(() {
          _currentLocationWeather = cachedCurrent;
        });
      }
    } catch (e) {
      print('Error loading cached current weather: $e');
    }

    for (var city in _savedCities) {
      try {
        final cachedWeather = await _dbHelper.getAnyWeather(city);
        if (cachedWeather != null) {
          setState(() {
            _weatherData[city] = cachedWeather;
          });
        }
      } catch (e) {
        print('Error loading cached weather for $city: $e');
      }
    }

    setState(() {
      _isLoading = false; // Show cached data
    });

    // --- Step 2: Fetch fresh data from network ---
    try {
      setState(() {
        _loadingMessage = 'Requesting location permission...';
      });
      final position = await _weatherService.getCurrentPosition();

      setState(() {
        _loadingMessage = 'Fetching weather for your location...';
      });
      final freshCurrent = await _weatherService.fetchWeatherByPosition(position);
      setState(() {
        _currentLocationWeather = freshCurrent;
      });
    } catch (e) {
      print('Error fetching fresh current weather: $e');
      setState(() {
        _loadingMessage = 'Could not fetch current location.';
      });
    }

    for (var city in _savedCities) {
      try {
        final freshWeather = await _weatherService.fetchWeatherByCity(city);
        setState(() {
          _weatherData[city] = freshWeather;
        });
      } catch (e) {
        print('Error fetching fresh weather for $city: $e');
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Weather'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingMessage),
                ],
              ),
            )
          : _buildWeatherList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            await _loadAndRefreshData();
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildWeatherList() {
    if (_savedCities.isEmpty && _currentLocationWeather == null) {
      return Center(
        child: Text(
          _loadingMessage.isNotEmpty ? _loadingMessage : 'Add a city to get started!',
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView(
      children: [
        if (_currentLocationWeather != null)
          _buildWeatherCard(_currentLocationWeather!, isCurrentLocation: true),
        ..._savedCities.map((city) {
          final weather = _weatherData[city];
          if (weather == null) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withOpacity(0.5),
              child: ListTile(
                title: Text(city),
                subtitle: const Text('Could not load weather data.'),
              ),
            );
          }
          return _buildWeatherCard(weather);
        }).toList(),
      ],
    );
  }

  Widget _buildWeatherCard(Weather weather, {bool isCurrentLocation = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isCurrentLocation ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap: () async {
          await _saveLastOpenedCity(weather.locationName);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherDetailScreen(weather: weather),
            ),
          );
          await _clearLastOpenedCity();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isCurrentLocation)
                        const Icon(Icons.location_on, size: 20),
                      if (isCurrentLocation)
                        const SizedBox(width: 8),
                      Text(
                        weather.locationName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.condition,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.network(
                    weather.iconUrl,
                    height: 40,
                    width: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).slideY();
  }
}
