import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DewPointDetailScreen extends StatelessWidget {
  final double dewPoint;
  final bool isFahrenheit;

  const DewPointDetailScreen({super.key, required this.dewPoint, required this.isFahrenheit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dew Point'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentDewPoint(),
            const SizedBox(height: 24),
            _buildDewPointInfo(),
            const SizedBox(height: 24),
            _buildAdvice(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentDewPoint() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Current Dew Point',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isFahrenheit ? '${dewPoint.round()}°F' : '${dewPoint.round()}°C',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _buildDewPointInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is Dew Point?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'The dew point is the temperature to which air must be cooled to become saturated with water vapor. When cooled further, the airborne water vapor will condense to form liquid water (dew). A higher dew point indicates more moisture in the air and can make the temperature feel more humid.',
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
          'Comfort Level',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _getDewPointAdvice(dewPoint),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _getDewPointAdvice(double temp) {
    final tempC = isFahrenheit ? (temp - 32) * 5 / 9 : temp;
    if (tempC >= 24) {
      return 'Extremely uncomfortable and oppressive. It will feel very muggy.';
    } else if (tempC >= 21) {
      return 'Very humid and uncomfortable.';
    } else if (tempC >= 18) {
      return 'Somewhat uncomfortable for most people.';
    } else if (tempC >= 16) {
      return 'Okay for most, but feels a bit humid.';
    } else if (tempC >= 10) {
      return 'Comfortable.';
    } else {
      return 'A bit dry for some.';
    }
  }
}
