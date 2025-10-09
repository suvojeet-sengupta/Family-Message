import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CurrentWeather extends StatelessWidget {
  final Weather weather;
  final bool isFahrenheit;

  const CurrentWeather({super.key, required this.weather, this.isFahrenheit = false});

  String _getFeelsLikeExplanation() {
    final temp = isFahrenheit ? weather.temperatureF : weather.temperature;
    final feelsLike = isFahrenheit ? weather.feelsLikeF : weather.feelsLike;

    if ((feelsLike - temp).abs() < 2) {
      return 'Similar to the actual temperature.';
    }
    if (feelsLike < temp) {
      return 'Feels colder due to the wind.';
    }
    if (feelsLike > temp) {
      return 'Feels warmer due to humidity.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.locationName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFahrenheit
                          ? '${weather.temperatureF.round()}°F'
                          : '${weather.temperature.round()}°C',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 80,
                            fontWeight: FontWeight.w200,
                          ),
                    ),
                    Text(
                      weather.condition,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                (weather.iconUrl.startsWith('https://cdn.weatherapi.com')
                    ? Image.network(
                        weather.iconUrl,
                        height: 100, // Slightly larger icon
                        width: 100,
                      )
                    : const SizedBox(
                        height: 100,
                        width: 100,
                      )),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.thermostat, color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Feels like ${isFahrenheit ? weather.feelsLikeF.round() : weather.feelsLike.round()}°',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getFeelsLikeExplanation(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.update, color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${weather.last_updated}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }
}
