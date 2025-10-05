import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;

  const HourlyForecastWidget({super.key, required this.hourlyForecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HOURLY FORECAST',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForecast.length,
                itemBuilder: (context, index) {
                  final forecast = hourlyForecast[index];
                  return _buildForecastItem(
                    time: DateFormat.j().format(DateTime.parse(forecast.time)),
                    iconUrl: forecast.iconUrl,
                    temperature: '${forecast.temperature.round()}°',
                  ).animate().fade(duration: 500.ms, delay: (100 * index).ms).slideX();
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.5);
  }

  Widget _buildForecastItem({required String time, required String iconUrl, required String temperature}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(
            iconUrl,
            height: 40,
            width: 40,
          ),
          const SizedBox(height: 8),
          Text(
            temperature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}