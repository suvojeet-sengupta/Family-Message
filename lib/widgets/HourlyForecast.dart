import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/hourly_forecast_detail_screen.dart';
import '../services/settings_service.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;

  const HourlyForecastWidget({super.key, required this.hourlyForecast});

  @override
  Widget build(BuildContext context) {
    final isFahrenheit = Provider.of<SettingsService>(context).useFahrenheit;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HourlyForecastDetailScreen(hourlyForecast: hourlyForecast, isFahrenheit: isFahrenheit),
          ),
        );
      },
      child: Card(
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
                'HOURLY FORECAST',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyForecast.length,
                  itemBuilder: (context, index) {
                    final forecast = hourlyForecast[index];
                    return _buildForecastItem(
                      time: DateFormat.j().format(DateTime.parse(forecast.time)),
                      iconUrl: forecast.iconUrl,
                      temperature: isFahrenheit
                          ? '${forecast.temperatureF.round()}°F'
                          : '${forecast.temperature.round()}°C',
                    ).animate().fade(duration: 300.ms);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildForecastItem({required String time, required String iconUrl, required String temperature}) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Image.network(
              iconUrl,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 8),
            Text(
              temperature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}