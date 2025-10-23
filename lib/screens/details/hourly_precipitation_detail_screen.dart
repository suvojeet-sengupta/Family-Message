import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';

class HourlyPrecipitationDetailScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;

  const HourlyPrecipitationDetailScreen({super.key, required this.hourlyForecast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Precipitation Chance'),
      ),
      body: ListView.builder(
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecast[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.j().format(DateTime.parse(forecast.time)),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${forecast.chanceOfRain}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 300.ms);
        },
      ),
    );
  }
}
