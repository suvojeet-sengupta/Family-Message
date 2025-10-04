import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
