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
                    colors: [Colors.orange.shade200, Colors.blue.shade200],
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: CustomPaint(
                          painter: SunPathPainter(sunPercentage),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 120,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTimeInfo(context, Icons.wb_sunny, 'Sunrise', _formatTime(sunrise)),
                                    _buildTimeInfo(context, Icons.brightness_3, 'Sunset', _formatTime(sunset)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class SunPathPainter extends CustomPainter {
  final double sunPercentage;

  SunPathPainter(this.sunPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 2, -size.height * 0.2, size.width, size.height * 0.8);
    canvas.drawPath(path, paint);

    final sunPaint = Paint()..color = Colors.yellow.shade600;
    final sunX = size.width * sunPercentage;
    final y = -0.008 * math.pow(sunX - size.width / 2, 2) + size.height * 0.8;

    canvas.drawCircle(Offset(sunX, y), 12, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}