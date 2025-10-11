import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class FeelsLikeDetailScreen extends StatelessWidget {
  final double feelsLike;
  final TemperatureUnit temperatureUnit;

  const FeelsLikeDetailScreen({super.key, required this.feelsLike, required this.temperatureUnit});

  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  @override
  Widget build(BuildContext context) {
    final displayFeelsLike = temperatureUnit == TemperatureUnit.fahrenheit
        ? feelsLike
        : _fahrenheitToCelsius(feelsLike); // Assuming feelsLike is always passed in Fahrenheit from WeatherInfo
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feels Like'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentFeelsLike(displayFeelsLike, tempUnitSymbol),
            const SizedBox(height: 24),
            _buildFeelsLikeInfo(),
            const SizedBox(height: 24),
            _buildAdvice(displayFeelsLike),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentFeelsLike(double displayFeelsLike, String tempUnitSymbol) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Currently Feels Like',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${displayFeelsLike.round()}$tempUnitSymbol',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelsLikeInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is "Feels Like" Temperature?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'The "feels like" temperature is a measure of how the temperature is perceived by humans, taking into account environmental factors like wind speed and humidity. It provides a more accurate representation of how comfortable or uncomfortable outdoor conditions will feel to a person.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAdvice(double displayFeelsLike) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'General Advice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _getFeelsLikeAdvice(displayFeelsLike),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getFeelsLikeAdvice(double temp) {
    // Convert to Celsius for advice logic, as the advice thresholds are likely based on Celsius.
    final tempC = temperatureUnit == TemperatureUnit.fahrenheit ? _fahrenheitToCelsius(temp) : temp;

    if (tempC > 30) {
      return 'It feels very hot. Stay hydrated, seek shade, and avoid strenuous activity during the hottest parts of the day.';
    } else if (tempC > 20) {
      return 'It feels warm and pleasant. Enjoy the weather, but remember to stay hydrated.';
    } else if (tempC > 10) {
      return 'It feels cool. A light jacket or sweater is recommended.';
    } else {
      return 'It feels cold. Dress in warm layers, and be mindful of wind chill.';
    }
  }
}
