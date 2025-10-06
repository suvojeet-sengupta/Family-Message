import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class AirQualityDetailScreen extends StatelessWidget {
  final AirQuality? airQuality;

  const AirQualityDetailScreen({super.key, this.airQuality});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Air Quality Index (AQI)', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      airQuality?.usEpaIndex.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getAqiSubtitle(airQuality?.usEpaIndex),
                      style: TextStyle(fontSize: 24, color: _getAqiColor(airQuality?.usEpaIndex)),
                    ),
                  ],
                ), 
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Air quality is a measure of how clean or polluted the air is. The Air Quality Index (AQI) is a scale used to report the quality of the air. A lower AQI value indicates cleaner air, while a higher value indicates more polluted air.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _getAqiSubtitle(int? aqi) {
    if (aqi == null) return 'N/A';
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Moderate';
      case 3:
        return 'Unhealthy for sensitive groups';
      case 4:
        return 'Unhealthy';
      case 5:
        return 'Very Unhealthy';
      case 6:
        return 'Hazardous';
      default:
        return 'Unknown';
    }
  }

  Color _getAqiColor(int? aqi) {
    if (aqi == null) return Colors.white;
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.brown;
      default:
        return Colors.white;
    }
  }
}
