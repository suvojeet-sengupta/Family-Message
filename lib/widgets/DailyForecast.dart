import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/daily_detail_screen.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const DailyForecastWidget({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    final fiveDayForecast = dailyForecast.take(5).toList();

    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5-DAY FORECAST',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fiveDayForecast.length,
              itemBuilder: (context, index) {
                final forecast = fiveDayForecast[index];
                return _buildForecastItem(context, forecast);
              },
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.5);
  }

  Widget _buildForecastItem(BuildContext context, DailyForecast forecast) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyDetailScreen(dailyForecast: forecast),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  DateFormat.E().format(DateTime.parse(forecast.date)),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              Image.network(
                forecast.iconUrl,
                height: 32,
                width: 32,
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${forecast.maxTemp.round()}°',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${forecast.minTemp.round()}°',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms).slideX();
  }
}
