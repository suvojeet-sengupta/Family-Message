import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyDetailScreen extends StatelessWidget {
  final DailyForecast dailyForecast;
  final bool isFahrenheit;

  const DailyDetailScreen({super.key, required this.dailyForecast, required this.isFahrenheit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMEd().format(DateTime.parse(dailyForecast.date))),
      ),
      body: ListView.builder(
        itemCount: dailyForecast.hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = dailyForecast.hourlyForecast[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.j().format(DateTime.parse(forecast.time)),
                    style: const TextStyle(fontSize: 16),
                  ),
                  (forecast.iconUrl.startsWith('https://cdn.weatherapi.com')
                      ? Image.network(
                          forecast.iconUrl,
                          height: 40,
                          width: 40,
                        )
                      : const SizedBox(
                          height: 40,
                          width: 40,
                        )),
                  Text(
                    isFahrenheit
                        ? '${forecast.temperatureF.round()}°F'
                        : '${forecast.temperature.round()}°C',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 300.ms);
        },
      ),
    );
  }
}
