import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class HourlyForecastDetailScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;
  final TemperatureUnit temperatureUnit;

  const HourlyForecastDetailScreen({super.key, required this.hourlyForecast, required this.temperatureUnit});

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  @override
  Widget build(BuildContext context) {
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Forecast'),
      ),
      body: ListView.builder(
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecast[index];
          final displayTemp = temperatureUnit == TemperatureUnit.fahrenheit
              ? _celsiusToFahrenheit(forecast.temperature)
              : forecast.temperature;

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
                    '${displayTemp.round()}$tempUnitSymbol',
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
