import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../screens/weather_detail_screen.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isFahrenheit;

  const WeatherCard({super.key, required this.weather, this.isFahrenheit = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherDetailScreen(weather: weather),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.locationName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.condition,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.dailyForecast.first.maxTemp.round()}° ${weather.dailyForecast.first.minTemp.round()}°',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  (weather.iconUrl.startsWith('https://cdn.weatherapi.com')
                      ? Image.network(
                          weather.iconUrl,
                          height: 40,
                          width: 40,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        )
                      : const SizedBox(
                          height: 40,
                          width: 40,
                        )),
                  const SizedBox(width: 8),
                  Text(
                    isFahrenheit
                        ? '${weather.temperatureF.round()}°'
                        : '${weather.temperature.round()}°',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).slideY();
  }
}