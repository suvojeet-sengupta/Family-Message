import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeelsLikeDetailScreen extends StatelessWidget {
  final double feelsLike;

  const FeelsLikeDetailScreen({super.key, required this.feelsLike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feels Like'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentFeelsLike(),
            const SizedBox(height: 24),
            _buildFeelsLikeInfo(),
            const SizedBox(height: 24),
            _buildAdvice(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentFeelsLike() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Currently Feels Like',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${feelsLike.round()}°',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelsLikeInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is "Feels Like" Temperature?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'The "feels like" temperature is a measure of how the temperature is perceived by humans, taking into account environmental factors like wind speed and humidity. It provides a more accurate representation of how comfortable or uncomfortable outdoor conditions will feel to a person.',
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
          'General Advice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _getFeelsLikeAdvice(feelsLike),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getFeelsLikeAdvice(double temp) {
    if (temp > 30) {
      return 'It feels very hot. Stay hydrated, seek shade, and avoid strenuous activity during the hottest parts of the day.';
    } else if (temp > 20) {
      return 'It feels warm and pleasant. Enjoy the weather, but remember to stay hydrated.';
    } else if (temp > 10) {
      return 'It feels cool. A light jacket or sweater is recommended.';
    } else {
      return 'It feels cold. Dress in warm layers, and be mindful of wind chill.';
    }
  }
}
