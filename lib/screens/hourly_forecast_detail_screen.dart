import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HourlyForecastDetailScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;

  const HourlyForecastDetailScreen({super.key, required this.hourlyForecast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Forecast'),
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
                  Image.network(
                    forecast.iconUrl,
                    height: 40,
                    width: 40,
                  ),
                  Text(
                    '${forecast.temperature.round()}°',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
