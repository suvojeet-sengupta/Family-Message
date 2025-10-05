import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/uv_index_detail_screen.dart';
import '../screens/feels_like_detail_screen.dart';
import '../screens/wind_detail_screen.dart';
import '../screens/humidity_detail_screen.dart';

class WeatherInfo extends StatelessWidget {
  final Weather weather;

  const WeatherInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeelsLikeDetailScreen(feelsLike: weather.feelsLike),
                      ),
                    );
                  },
                  child: _buildInfoItem(Icons.thermostat, 'Feels Like', '${weather.feelsLike.round()}°'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WindDetailScreen(windSpeedKph: weather.wind),
                      ),
                    );
                  },
                  child: _buildInfoItem(Icons.air, 'Wind', '${weather.wind.round()} km/h'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HumidityDetailScreen(humidity: weather.humidity),
                      ),
                    );
                  },
                  child: _buildInfoItem(Icons.water_drop, 'Humidity', '${weather.humidity}%'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UvIndexDetailScreen(uvIndex: weather.uvIndex),
                      ),
                    );
                  },
                  child: _buildInfoItem(Icons.wb_sunny, 'UV Index', '${weather.uvIndex.round()}'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
