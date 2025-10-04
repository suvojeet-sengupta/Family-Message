import 'package:flutter/material.dart';
import 'services/weather_service.dart';
import 'models/weather_model.dart';
import 'widgets/CurrentWeather.dart';
import 'widgets/WeatherInfo.dart';
import 'widgets/HourlyForecast.dart';
import 'widgets/DailyForecast.dart';
import 'screens/search_screen.dart';
import 'services/database_helper.dart';

void main() {
  runApp(const AuroraWeather());
}

class AuroraWeather extends StatelessWidget {
  const AuroraWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuroraWeather',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First, try to load data from the cache to display something immediately
      final cachedWeather = await _dbHelper.getLatestWeather();
      if (cachedWeather != null) {
        setState(() {
          _weather = cachedWeather;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Ignore errors from cache loading, as fresh data will be fetched anyway
    }

    // Now, fetch fresh data from the API
    await _fetchWeather();
  }

  Future<void> _fetchWeather({String? city}) async {
    // Only show loading indicator if there's no data to display
    if (_weather == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final weather = await (city == null
          ? _weatherService.fetchWeather()
          : _weatherService.fetchWeatherByCity(city));
      setState(() {
        _weather = weather;
        _isLoading = false;
        _errorMessage = null; // Clear any previous error
      });
    } catch (e) {
      // Only show error if there's no cached data to display
      if (_weather == null) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33),
      appBar: AppBar(
        title: const Text('AuroraWeather'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // TODO: Implement profile screen
          },
        ),
      ),
      body: Center(
        child: _buildWeatherContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (selectedCity != null) {
            _fetchWeather(city: selectedCity);
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_weather == null) {
      return const Text(
        'No weather data available.',
        style: TextStyle(fontSize: 18),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CurrentWeather(weather: _weather!),
            const SizedBox(height: 24),
            WeatherInfo(weather: _weather!),
            const SizedBox(height: 24),
            HourlyForecastWidget(hourlyForecast: _weather!.hourlyForecast),
            const SizedBox(height: 24),
            DailyForecastWidget(dailyForecast: _weather!.dailyForecast),
          ],
        ),
      ),
    );
  }
}