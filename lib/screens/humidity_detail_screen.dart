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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentHumidity(),
            const SizedBox(height: 24),
            _buildHumidityInfo(),
            const SizedBox(height: 24),
            _buildAdvice(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentHumidity() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Current Humidity',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$humidity%',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is Relative Humidity?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Relative humidity is a measure of the amount of water vapor present in the air, expressed as a percentage of the maximum amount of water vapor the air can hold at a specific temperature.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAdvice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comfort & Health Advice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _getHumidityAdvice(humidity),
          style: const TextStyle(fontSize: 16),
        ),
      ],
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
