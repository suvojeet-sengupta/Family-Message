import 'package:flutter/material.dart';

class SunriseSunsetDetailScreen extends StatelessWidget {
  final String sunrise;
  final String sunset;

  const SunriseSunsetDetailScreen({super.key, required this.sunrise, required this.sunset});

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
                              sunrise.isNotEmpty ? sunrise.substring(11, 16) : 'N/A',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Sunset', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              sunset.isNotEmpty ? sunset.substring(11, 16) : 'N/A',
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
