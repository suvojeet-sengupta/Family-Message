import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SunriseSunsetDetailScreen extends StatelessWidget {
  final String sunrise;
  final String sunset;

  const SunriseSunsetDetailScreen({super.key, required this.sunrise, required this.sunset});

  String _formatTime(String time) {
    if (time.isEmpty) {
      return 'N/A';
    }
    final dateTime = DateTime.parse(time);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunrise & Sunset'),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Sunrise', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(sunrise),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Sunset', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(sunset),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
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
}
