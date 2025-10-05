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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCitiesAndFetchWeather();
  }

  Future<void> _loadSavedCitiesAndFetchWeather() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList('recentSearches') ?? [];
    });

    if (_savedCities.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

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
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newCity = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
              if (newCity != null && newCity.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                await _loadSavedCitiesAndFetchWeather();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildWeatherList(),
    );
  }

  Widget _buildWeatherList() {
    if (_savedCities.isEmpty) {
      return const Center(
        child: Text(
          'Add a city to get started!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: _savedCities.length,
      itemBuilder: (context, index) {
        final city = _savedCities[index];
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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white.withOpacity(0.1),
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
                      Text(
                        weather.locationName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
        ).animate().fade(duration: 300.ms).slideY(delay: (100 * index).ms);
      },
    );
  }
}