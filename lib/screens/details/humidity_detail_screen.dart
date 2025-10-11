import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HumidityDetailScreen extends StatelessWidget {
  final int humidity;

  const HumidityDetailScreen({super.key, required this.humidity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Humidity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentHumidity(context),
            const SizedBox(height: 24),
            _buildHumidityInfo(context),
            const SizedBox(height: 24),
            _buildAdvice(context),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentHumidity(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Current Humidity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.water_drop_outlined, size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Text(
                  '$humidity%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Relative Humidity?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Relative humidity is a measure of the amount of water vapor present in the air, expressed as a percentage of the maximum amount of water vapor the air can hold at a specific temperature.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvice(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comfort & Health Advice',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getHumidityAdvice(humidity),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _getHumidityAdvice(int humidity) {
    if (humidity > 60) {
      return 'High humidity can make it feel warmer than it is and can promote the growth of mold and mildew. An air conditioner or dehumidifier can help you feel more comfortable.';
    } else if (humidity < 40) {
      return 'Low humidity can dry out your skin and nasal passages. A humidifier can help add moisture to the air.';
    } else {
      return 'The current humidity level is in the ideal range for comfort and health (40-60%).';
    }
  }
}