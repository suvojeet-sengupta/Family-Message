import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('US EPA Air Quality Index (AQI)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      airQuality?.usEpaIndex.round().toString() ?? 'N/A',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getAqiSubtitle(airQuality?.usEpaIndex),
                      style: TextStyle(fontSize: 24, color: _getAqiColor(context, airQuality?.usEpaIndex), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      _getAqiAdvice(airQuality?.usEpaIndex),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAqiSubtitle(num? aqi) {
    if (aqi == null) return 'N/A';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(BuildContext context, num? aqi) {
    if (aqi == null) return Theme.of(context).colorScheme.onSurface;
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAqiAdvice(num? aqi) {
    if (aqi == null) return 'No data available.';
    if (aqi <= 50) return 'Air quality is excellent. It\'s a great day for outdoor activities.';
    if (aqi <= 100) return 'Air quality is acceptable. Unusually sensitive people should consider reducing prolonged or heavy exertion.';
    if (aqi <= 150) return 'People with respiratory or heart disease, the elderly, and children should limit prolonged exertion.';
    if (aqi <= 200) return 'Everyone may begin to experience health effects. People with respiratory or heart disease, the elderly, and children should avoid prolonged exertion.';
    if (aqi <= 300) return 'Health alert: everyone may experience more serious health effects. Avoid all outdoor exertion.';
    return 'Health warning of emergency conditions. The entire population is more likely to be affected.';
  }
}