import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';

class UvIndexDetailScreen extends StatelessWidget {
  final Weather weather;

  const UvIndexDetailScreen({super.key, required this.weather});

  String _getUvIndexDescription(double uvIndex) {
    if (uvIndex <= 2) {
      return 'Low';
    } else if (uvIndex <= 5) {
      return 'Moderate';
    } else if (uvIndex <= 7) {
      return 'High';
    } else if (uvIndex <= 10) {
      return 'Very High';
    } else {
      return 'Extreme';
    }
  }

  String _getUvIndexAdvice(double uvIndex) {
    if (uvIndex <= 2) {
      return 'No protection needed. You can safely stay outside.';
    } else if (uvIndex <= 5) {
      return 'Protection needed. Seek shade during midday hours, cover up, and use sunscreen.';
    } else if (uvIndex <= 7) {
      return 'Protection essential. Seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    } else if (uvIndex <= 10) {
      return 'Extra protection needed. Avoid being outside during midday hours. Seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    } else {
      return 'Stay inside! Avoid being outside during midday hours. If you must be outside, seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    }
  }

  Color _getUvIndexColor(double uvIndex) {
    if (uvIndex <= 2) {
      return Colors.green;
    } else if (uvIndex <= 5) {
      return Colors.yellow;
    } else if (uvIndex <= 7) {
      return Colors.orange;
    } else if (uvIndex <= 10) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UV Index'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentUvIndex(context),
            const SizedBox(height: 24),
            _buildHourlyUvIndex(context),
            const SizedBox(height: 24),
            _buildDailyUvIndex(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUvIndex(BuildContext context) {
    final uvIndex = weather.uvIndex;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current UV Index', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              uvIndex.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getUvIndexDescription(uvIndex),
              style: TextStyle(fontSize: 24, color: _getUvIndexColor(uvIndex), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              _getUvIndexAdvice(uvIndex),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyUvIndex(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hourly UV Index', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.hourlyForecast.length,
            itemBuilder: (context, index) {
              final hourly = weather.hourlyForecast[index];
              return Card(
                margin: const EdgeInsets.only(right: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('h a').format(DateTime.parse(hourly.time))),
                      const SizedBox(height: 8),
                      Text(
                        hourly.uv.toStringAsFixed(1),
                        style: TextStyle(fontSize: 20, color: _getUvIndexColor(hourly.uv), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyUvIndex(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily UV Index', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weather.dailyForecast.length,
          itemBuilder: (context, index) {
            final daily = weather.dailyForecast[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('EEEE, MMM d').format(DateTime.parse(daily.date))),
                    Text(
                      daily.uv.toStringAsFixed(1),
                      style: TextStyle(fontSize: 20, color: _getUvIndexColor(daily.uv), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}