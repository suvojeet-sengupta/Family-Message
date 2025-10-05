import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'search_screen.dart';
import 'weather_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  List<String> _savedCities = [];
  Map<String, Weather> _weatherData = {};
  Weather? _currentLocationWeather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllWeatherData();
  }

  Future<void> _fetchAllWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch current location weather
    try {
      final weather = await _weatherService.fetchWeather();
      setState(() {
        _currentLocationWeather = weather;
      });
    } catch (e) {
      print('Error fetching current location weather: $e');
    }

    // Fetch weather for saved cities
    final prefs = await SharedPreferences.getInstance();
    _savedCities = prefs.getStringList('recentSearches') ?? [];

    for (var city in _savedCities) {
      try {
        final weather = await _weatherService.fetchWeatherByCity(city);
        setState(() {
          _weatherData[city] = weather;
        });
      } catch (e) {
        print('Error fetching weather for $city: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Weather'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildWeatherList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            await _fetchAllWeatherData();
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildWeatherList() {
    if (_savedCities.isEmpty && _currentLocationWeather == null) {
      return const Center(
        child: Text(
          'Add a city to get started!',
          style: TextStyle(fontSize: 18),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherDetailScreen(weather: weather),
            ),
          );
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