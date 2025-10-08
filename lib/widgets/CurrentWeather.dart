import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;
  final bool isFahrenheit;

  const CurrentWeather({super.key, required this.weather, this.isFahrenheit = false});

  String _getFeelsLikeExplanation() {
    final temp = isFahrenheit ? weather.temperatureF : weather.temperature;
    final feelsLike = isFahrenheit ? weather.feelsLikeF : weather.feelsLike;

    if ((feelsLike - temp).abs() < 2) {
      return 'Similar to the actual temperature.';
    }
    if (feelsLike < temp) {
      return 'Feels colder due to the wind.';
    }
    if (feelsLike > temp) {
      return 'Feels warmer due to humidity.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.locationName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFahrenheit
                          ? '${weather.temperatureF.round()}°F'
                          : '${weather.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 80, // Slightly smaller
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      weather.condition,
                      style: const TextStyle(
                        fontSize: 20, // Slightly smaller
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Image.network(
                  weather.iconUrl,
                  height: 100, // Slightly larger icon
                  width: 100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Feels like ${isFahrenheit ? weather.feelsLikeF.round() : weather.feelsLike.round()}°',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getFeelsLikeExplanation(),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.update, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${weather.last_updated}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }
}
