import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SunriseSunsetDetailScreen extends StatelessWidget {
  final String date;
  final String sunrise;
  final String sunset;

  const SunriseSunsetDetailScreen({super.key, required this.date, required this.sunrise, required this.sunset});

  String _formatTime(String time) {
    if (time.isEmpty || date.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $time");
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  String _calculateDaylight(String sunrise, String sunset) {
    if (sunrise.isEmpty || sunset.isEmpty || date.isEmpty) {
      return 'N/A';
    }
    try {
      final sunriseTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunrise");
      final sunsetTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunset");
      final duration = sunsetTime.difference(sunriseTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '$hours hours $minutes minutes';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunrise & Sunset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.amber, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sunrise', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(
                          _formatTime(sunrise),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.brightness_3, color: Colors.blue, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sunset', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(
                          _formatTime(sunset),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_bottom, color: Colors.white70, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Daylight: ${_calculateDaylight(sunrise, sunset)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}