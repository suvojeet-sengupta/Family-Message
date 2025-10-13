
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AuroraWeather/models/weather_model.dart';

class ShareableWeatherWidget extends StatelessWidget {
  final Weather weather;

  const ShareableWeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            weather.locationName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${weather.temperature.round()}°C',
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          Text(
            weather.condition,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aurora Weather',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            DateFormat.yMMMd().add_jm().format(DateTime.now()),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
