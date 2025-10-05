import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/uv_index_detail_screen.dart';
import '../screens/feels_like_detail_screen.dart';
import '../screens/wind_detail_screen.dart';
import '../screens/humidity_detail_screen.dart';
import '../services/settings_service.dart';

class WeatherInfo extends StatefulWidget {
  final Weather weather;

  const WeatherInfo({super.key, required this.weather});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  final SettingsService _settingsService = SettingsService();
  bool _isFahrenheit = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isFahrenheit = await _settingsService.isFahrenheit();
    setState(() {});
  }

  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

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
                      _createFadeRoute(FeelsLikeDetailScreen(feelsLike: _isFahrenheit ? widget.weather.feelsLikeF : widget.weather.feelsLike, isFahrenheit: _isFahrenheit)),
                    );
                  },
                  child: _buildInfoItem(Icons.thermostat, 'Feels Like', _isFahrenheit ? '${widget.weather.feelsLikeF.round()}°F' : '${widget.weather.feelsLike.round()}°C'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      _createFadeRoute(WindDetailScreen(windSpeedKph: widget.weather.wind)),
                    );
                  },
                  child: _buildInfoItem(Icons.air, 'Wind', '${widget.weather.wind.round()} km/h'),
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
                      _createFadeRoute(HumidityDetailScreen(humidity: widget.weather.humidity)),
                    );
                  },
                  child: _buildInfoItem(Icons.water_drop, 'Humidity', '${widget.weather.humidity}%'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      _createFadeRoute(UvIndexDetailScreen(uvIndex: widget.weather.uvIndex)),
                    );
                  },
                  child: _buildInfoItem(Icons.wb_sunny, 'UV Index', '${widget.weather.uvIndex.round()}'),
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