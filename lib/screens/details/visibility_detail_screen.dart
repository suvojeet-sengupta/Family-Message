import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VisibilityDetailScreen extends StatelessWidget {
  final double visKm;
  final double visMiles;

  const VisibilityDetailScreen({super.key, required this.visKm, required this.visMiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visibility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentVisibility(),
            const SizedBox(height: 24),
            _buildVisibilityInfo(),
            const SizedBox(height: 24),
            _buildAdvice(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentVisibility() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Current Visibility',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$visKm km',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
          Text(
            '($visMiles miles)',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is Visibility?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Visibility is a measure of the distance at which an object or light can be clearly discerned. In meteorology, it is an estimate of the distance at which a person can clearly see a large object.',
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
          _getVisibilityAdvice(visKm),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getVisibilityAdvice(double km) {
    if (km > 10) {
      return 'Excellent visibility. Great for outdoor activities and travel.';
    } else if (km > 5) {
      return 'Good visibility. Conditions are clear for most activities.';
    } else if (km > 2) {
      return 'Moderate visibility. Be cautious while driving, especially at high speeds.';
    } else if (km > 1) {
      return 'Poor visibility. Drive with extreme caution, use fog lights if necessary.';
    } else {
      return 'Very poor visibility (fog or heavy precipitation). Travel is not recommended if possible.';
    }
  }
}
