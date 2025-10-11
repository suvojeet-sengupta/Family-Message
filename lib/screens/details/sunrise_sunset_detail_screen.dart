import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

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

  String _calculateSolarNoon(String sunrise, String sunset) {
    if (sunrise.isEmpty || sunset.isEmpty || date.isEmpty) {
      return 'N/A';
    }
    try {
      final sunriseTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunrise");
      final sunsetTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunset");
      final noonMillis = (sunriseTime.millisecondsSinceEpoch + sunsetTime.millisecondsSinceEpoch) ~/ 2;
      final noonTime = DateTime.fromMillisecondsSinceEpoch(noonMillis);
      return DateFormat('h:mm a').format(noonTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sunriseTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunrise");
    final sunsetTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunset");

    double sunPercentage = 0.0;
    if (now.isAfter(sunriseTime) && now.isBefore(sunsetTime)) {
      sunPercentage = now.difference(sunriseTime).inMinutes / sunsetTime.difference(sunriseTime).inMinutes;
    } else if (now.isAfter(sunsetTime)) {
      sunPercentage = 1.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunrise & Sunset'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daylight: ${_calculateDaylight(sunrise, sunset)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: CustomPaint(
                          painter: SunPathPainter(
                            sunPercentage: sunPercentage,
                            pathColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            sunColor: Colors.amber,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTimeInfo(context, Icons.wb_sunny, 'Sunrise', _formatTime(sunrise)),
                          _buildTimeInfo(context, Icons.brightness_3, 'Sunset', _formatTime(sunset)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSolarNoonCard(context),
            const SizedBox(height: 16),
            _buildDaylightInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarNoonCard(BuildContext context) {
    final solarNoon = _calculateSolarNoon(sunrise, sunset);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solar Noon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flare, color: Colors.orange),
                const SizedBox(width: 12),
                Text(
                  solarNoon,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Solar noon is the moment when the Sun passes a location\'s meridian and reaches its highest position in the sky for that day.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaylightInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Daylight',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Daylight is the period of time each day between sunrise and sunset. The duration of daylight varies with the time of year and the latitude of the location.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, IconData icon, String label, String time) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class SunPathPainter extends CustomPainter {
  final double sunPercentage;
  final Color pathColor;
  final Color sunColor;

  SunPathPainter({required this.sunPercentage, required this.pathColor, required this.sunColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 2, -size.height * 0.2, size.width, size.height * 0.8);
    canvas.drawPath(path, paint);

    final sunPaint = Paint()..color = sunColor;
    final t = sunPercentage;
    final y0 = size.height * 0.8;
    final y1 = -size.height * 0.2;
    final y = math.pow(1 - t, 2) * y0 + 2 * (1 - t) * t * y1 + math.pow(t, 2) * y0;
    final sunX = size.width * t;

    canvas.drawCircle(Offset(sunX, y), 12, sunPaint);
  }

  @override
  bool shouldRepaint(covariant SunPathPainter oldDelegate) {
    return oldDelegate.sunPercentage != sunPercentage ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.sunColor != sunColor;
  }
}