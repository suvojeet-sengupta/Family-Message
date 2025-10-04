import 'package:flutter/material.dart';
import 'services/weather_service.dart';
import 'models/weather_model.dart';
import 'widgets/CurrentWeather.dart';
import 'widgets/WeatherInfo.dart';
import 'widgets/HourlyForecast.dart';
import 'widgets/DailyForecast.dart';

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
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather = await _weatherService.fetchWeather();
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
      ),
      body: Center(
        child: _buildWeatherContent(),
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