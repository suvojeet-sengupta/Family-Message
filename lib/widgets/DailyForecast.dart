import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/details/daily_detail_screen.dart';
import '../services/settings_service.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const DailyForecastWidget({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isFahrenheit = settingsService.useFahrenheit;
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
                return _buildForecastItem(context, forecast, isFahrenheit);
              },
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildForecastItem(BuildContext context, DailyForecast forecast, bool isFahrenheit) {
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
              builder: (context) => DailyDetailScreen(dailyForecast: forecast, isFahrenheit: isFahrenheit),
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
              (forecast.iconUrl.startsWith('https://cdn.weatherapi.com')
                  ? Image.network(
                      forecast.iconUrl,
                      height: 32,
                      width: 32,
                    )
                  : const SizedBox(
                      height: 32,
                      width: 32,
                    )),
              SizedBox(
                width: 50,
                child: Text(
                  isFahrenheit ? '${forecast.maxTempF.round()}°F' : '${forecast.maxTemp.round()}°C',
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
                  isFahrenheit ? '${forecast.minTempF.round()}°F' : '${forecast.minTemp.round()}°C',
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
    ).animate().fade(duration: 300.ms);
  }
}
