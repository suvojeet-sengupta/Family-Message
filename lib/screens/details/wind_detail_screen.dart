import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WindDetailScreen extends StatelessWidget {
  final double windSpeedKph;
  final int windDegree;
  final String windDir;

  const WindDetailScreen({
    super.key,
    required this.windSpeedKph,
    required this.windDegree,
    required this.windDir,
  });

  @override
  Widget build(BuildContext context) {
    final windSpeedMph = windSpeedKph * 0.621371;
    final beaufort = _getBeaufort(windSpeedMph);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wind'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWindSpeed(context, beaufort),
            const SizedBox(height: 24),
            _buildWindDirection(context),
            const SizedBox(height: 24),
            _buildBeaufortInfo(context),
            const SizedBox(height: 24),
            _buildBeaufortScale(context),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildWindDirection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Wind Direction',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.compass_calibration_outlined, size: 200, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                Transform.rotate(
                  angle: (windDegree * math.pi / 180) * -1, // Rotate clockwise
                  child: Icon(Icons.arrow_upward_rounded, size: 150, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$windDir ($windDegree°)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWindSpeed(BuildContext context, Map<String, dynamic> beaufort) {
    return Center(
      child: Column(
        children: [
          Text(
            'Current Wind Speed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${windSpeedKph.round()} km/h',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Beaufort Force ${beaufort['force']}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${beaufort['description']}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${beaufort['effects']}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeaufortInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Beaufort Scale',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'The Beaufort scale is an empirical measure that relates wind speed to observed conditions at sea or on land.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildBeaufortScale(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beaufort Scale Reference',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildScaleItem(context, 0, 'Calm', '0-1 mph'),
        _buildScaleItem(context, 1, 'Light Air', '1-3 mph'),
        _buildScaleItem(context, 2, 'Light Breeze', '4-7 mph'),
        _buildScaleItem(context, 3, 'Gentle Breeze', '8-12 mph'),
        _buildScaleItem(context, 4, 'Moderate Breeze', '13-18 mph'),
        _buildScaleItem(context, 5, 'Fresh Breeze', '19-24 mph'),
        _buildScaleItem(context, 6, 'Strong Breeze', '25-31 mph'),
        _buildScaleItem(context, 7, 'Near Gale', '32-38 mph'),
        _buildScaleItem(context, 8, 'Gale', '39-46 mph'),
        _buildScaleItem(context, 9, 'Strong Gale', '47-54 mph'),
        _buildScaleItem(context, 10, 'Storm', '55-63 mph'),
        _buildScaleItem(context, 11, 'Violent Storm', '64-75 mph'),
        _buildScaleItem(context, 12, 'Hurricane', '75+ mph'),
      ],
    );
  }

  Widget _buildScaleItem(BuildContext context, int force, String description, String speed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                force.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(speed, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getBeaufort(double mph) {
    if (mph < 1) return {'force': 0, 'description': 'Calm', 'effects': 'Smoke rises vertically.'};
    if (mph < 4) return {'force': 1, 'description': 'Light Air', 'effects': 'Wind direction shown by smoke drift.'};
    if (mph < 8) return {'force': 2, 'description': 'Light Breeze', 'effects': 'Wind felt on face; leaves rustle.'};
    if (mph < 13) return {'force': 3, 'description': 'Gentle Breeze', 'effects': 'Leaves and small twigs in constant motion.'};
    if (mph < 19) return {'force': 4, 'description': 'Moderate Breeze', 'effects': 'Raises dust and loose paper.'};
    if (mph < 25) return {'force': 5, 'description': 'Fresh Breeze', 'effects': 'Small trees in leaf begin to sway.'};
    if (mph < 32) return {'force': 6, 'description': 'Strong Breeze', 'effects': 'Large branches in motion.'};
    if (mph < 39) return {'force': 7, 'description': 'Near Gale', 'effects': 'Whole trees in motion.'};
    if (mph < 47) return {'force': 8, 'description': 'Gale', 'effects': 'Twigs break off trees.'};
    if (mph < 55) return {'force': 9, 'description': 'Strong Gale', 'effects': 'Slight structural damage.'};
    if (mph < 64) return {'force': 10, 'description': 'Storm', 'effects': 'Trees uprooted; considerable structural damage.'};
    if (mph < 76) return {'force': 11, 'description': 'Violent Storm', 'effects': 'Widespread damage.'};
    return {'force': 12, 'description': 'Hurricane', 'effects': 'Severe and extensive damage.'};
  }
}