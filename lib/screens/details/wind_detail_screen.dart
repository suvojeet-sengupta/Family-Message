import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_service.dart'; // Import SettingsService for WindSpeedUnit

class WindDetailScreen extends StatelessWidget {
  final double windSpeedKphRaw;
  final int windDegree;
  final String windDir;
  final WindSpeedUnit windSpeedUnit;

  const WindDetailScreen({
    super.key,
    required this.windSpeedKphRaw,
    required this.windDegree,
    required this.windDir,
    required this.windSpeedUnit,
  });

  double _kphToMph(double kph) {
    return kph * 0.621371;
  }

  double _kphToMs(double kph) {
    return kph * 1000 / 3600;
  }

  @override
  Widget build(BuildContext context) {
    double displayWindSpeed;
    String displayWindSpeedSymbol;
    double windSpeedMphForBeaufort;

    switch (windSpeedUnit) {
      case WindSpeedUnit.mph:
        displayWindSpeed = _kphToMph(windSpeedKphRaw);
        displayWindSpeedSymbol = 'mph';
        windSpeedMphForBeaufort = displayWindSpeed;
        break;
      case WindSpeedUnit.ms:
        displayWindSpeed = _kphToMs(windSpeedKphRaw);
        displayWindSpeedSymbol = 'm/s';
        windSpeedMphForBeaufort = _kphToMph(windSpeedKphRaw); // Beaufort scale is based on MPH, so convert raw KPH to MPH
        break;
      case WindSpeedUnit.kph:
      default:
        displayWindSpeed = windSpeedKphRaw;
        displayWindSpeedSymbol = 'km/h';
        windSpeedMphForBeaufort = _kphToMph(windSpeedKphRaw);
        break;
    }

    final beaufort = _getBeaufort(windSpeedMphForBeaufort);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wind Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWindCompass(context),
              const SizedBox(height: 48),
              _buildWindInfo(context, displayWindSpeed, displayWindSpeedSymbol, beaufort),
            ],
          ).animate().fade(duration: 300.ms),
        ),
      ),
    );
  }

  Widget _buildWindCompass(BuildContext context) {
    return Column(
      children: [
        Text(
          'Direction',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), width: 2),
                ),
              ),
              Transform.rotate(
                angle: (windDegree * math.pi / 180) * -1, // Rotate clockwise
                child: Icon(Icons.arrow_upward_rounded, size: 100, color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                windDir,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$windDegree°',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildWindInfo(BuildContext context, double displayWindSpeed, String displayWindSpeedSymbol, Map<String, dynamic> beaufort) {
    return Column(
      children: [
        Text(
          'Speed',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          '${displayWindSpeed.round()}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          displayWindSpeedSymbol,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Beaufort Force ${beaufort['force']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${beaufort['description']}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getBeaufort(double mph) {
    if (mph < 1) return {'force': 0, 'description': 'Calm'};
    if (mph < 4) return {'force': 1, 'description': 'Light Air'};
    if (mph < 8) return {'force': 2, 'description': 'Light Breeze'};
    if (mph < 13) return {'force': 3, 'description': 'Gentle Breeze'};
    if (mph < 19) return {'force': 4, 'description': 'Moderate Breeze'};
    if (mph < 25) return {'force': 5, 'description': 'Fresh Breeze'};
    if (mph < 32) return {'force': 6, 'description': 'Strong Breeze'};
    if (mph < 39) return {'force': 7, 'description': 'Near Gale'};
    if (mph < 47) return {'force': 8, 'description': 'Gale'};
    if (mph < 55) return {'force': 9, 'description': 'Strong Gale'};
    if (mph < 64) return {'force': 10, 'description': 'Storm'};
    if (mph < 76) return {'force': 11, 'description': 'Violent Storm'};
    return {'force': 12, 'description': 'Hurricane'};
  }
}