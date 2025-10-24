import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../services/settings_service.dart'; // Import SettingsService for WindSpeedUnit

class WindGustDetailScreen extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;
  final WindSpeedUnit windSpeedUnit;

  const WindGustDetailScreen({super.key, required this.hourlyForecast, required this.windSpeedUnit});

  double _kphToMph(double kph) {
    return kph * 0.621371;
  }

  double _kphToMs(double kph) {
    return kph * 1000 / 3600;
  }

  @override
  Widget build(BuildContext context) {
    String windSpeedSymbol;

    switch (windSpeedUnit) {
      case WindSpeedUnit.mph:
        windSpeedSymbol = 'mph';
        break;
      case WindSpeedUnit.ms:
        windSpeedSymbol = 'm/s';
        break;
      case WindSpeedUnit.kph:
      default:
        windSpeedSymbol = 'km/h';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Wind Gusts'),
      ),
      body: ListView.builder(
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecast[index];
          double? displayWindGust;

          if (forecast.windGustKph == null) {
            displayWindGust = null;
          } else {
            switch (windSpeedUnit) {
              case WindSpeedUnit.mph:
                displayWindGust = _kphToMph(forecast.windGustKph!);
                break;
              case WindSpeedUnit.ms:
                displayWindGust = _kphToMs(forecast.windGustKph!);
                break;
              case WindSpeedUnit.kph:
              default:
                displayWindGust = forecast.windGustKph!;
                break;
            }
          }

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
                  Row(
                    children: [
                      const Icon(Icons.wind_power, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        displayWindGust != null ? '${displayWindGust.round()} $windSpeedSymbol' : 'N/A',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
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
