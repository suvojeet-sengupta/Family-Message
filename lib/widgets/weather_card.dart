import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../screens/weather_detail_screen.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isFahrenheit;
  final bool isRefreshing;

  const WeatherCard({super.key, required this.weather, this.isFahrenheit = false, this.isRefreshing = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // Ensures the overlay respects the border radius
      color: Colors.grey[900],
      child: Stack(
        children: [
          InkWell(
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${weather.dailyForecast.first.maxTemp.round()}° ${weather.dailyForecast.first.minTemp.round()}°',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Image.network(
                        weather.iconUrl,
                        height: 40,
                        width: 40,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFahrenheit
                            ? '${weather.temperatureF.round()}°'
                            : '${weather.temperature.round()}°',
                        style: const TextStyle(
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
          if (isRefreshing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY();
  }
}
