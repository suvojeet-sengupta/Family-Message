
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AuroraWeather/models/weather_model.dart';

class ShareableWeatherWidget extends StatelessWidget {
  final Weather weather;

  const ShareableWeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final List<Color> gradientColors = isDarkMode
            ? [Colors.grey.shade800, Colors.grey.shade900]
            : [Colors.blue.shade200, Colors.blue.shade400];
        final Color textColor = isDarkMode ? Colors.white : Colors.black;
        final Color lightTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                weather.locationName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${weather.temperature.round()}°C',
                style: TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              Text(
                weather.condition,
                style: TextStyle(
                  fontSize: 22,
                  color: lightTextColor,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Aurora Weather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                DateFormat.yMMMd().add_jm().format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: lightTextColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
