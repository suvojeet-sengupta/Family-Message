import 'package:flutter/material.dart';
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
  final SettingsService _settingsService = SettingsService();
  List<String> _savedCities = [];
  Map<String, Weather> _weatherData = {};
  Weather? _currentLocationWeather;
  bool _isInitialLoading = true;
  String _loadingMessage = 'Initializing...';
  bool _isFahrenheit = false;

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
    _loadData();
  }

  Future<void> _loadData() async {
    _isFahrenheit = await _settingsService.isFahrenheit();
    await _loadCachedData();
    await _fetchFreshData();
  }

  Future<void> _loadCachedData() async {
    setState(() {
      _isInitialLoading = true;
      _loadingMessage = 'Loading saved locations...';
    });

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
      _isInitialLoading = false;
    });
  }

  Future<void> _fetchFreshData() async {
    // Fetch current location weather
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
      if (mounted) {
        setState(() {
          _loadingMessage = 'Could not fetch current location.';
        });
      }
    }

    // Fetch weather for saved cities
    for (var city in _savedCities) {
      try {
        final freshWeather = await _weatherService.fetchWeatherByCity(city);
        if(mounted) {
          setState(() {
            _weatherData[city] = freshWeather;
          });
        }
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
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _loadData();
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://www.gravatar.com/avatar/'),
            ),
          ),
        ],
      ),
      body: _isInitialLoading
          ? const ShimmerLoading()
          : _buildWeatherList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            await _loadData();
          }
        },
        backgroundColor: Colors.grey[800],
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

    return RefreshIndicator(
      onRefresh: _fetchFreshData,
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
            WeatherCard(weather: _currentLocationWeather!, isFahrenheit: _isFahrenheit),
          if (_currentLocationWeather == null)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Update location permissions'),
            ),
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.red.withOpacity(0.5),
                child: ListTile(
                  title: Text(city),
                  subtitle: const Text('Could not load weather data.'),
                ),
              );
            }
            return WeatherCard(weather: weather, isFahrenheit: _isFahrenheit);
          }).toList(),
        ],
      ),
    );
  }
}
