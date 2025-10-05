import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_service.dart';

class CurrentWeather extends StatefulWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.weather.locationName,
              style: const TextStyle(
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
                      _isFahrenheit
                          ? '${widget.weather.temperatureF.round()}°F'
                          : '${widget.weather.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 80, // Slightly smaller
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      widget.weather.condition,
                      style: const TextStyle(
                        fontSize: 20, // Slightly smaller
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Image.network(
                  widget.weather.iconUrl,
                  height: 100, // Slightly larger icon
                  width: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }
}
