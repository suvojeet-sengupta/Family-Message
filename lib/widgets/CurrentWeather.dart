import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              weather.locationName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Image.network(
              weather.iconUrl,
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.temperature.round()}°',
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weather.condition,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: -0.5);
  }
}