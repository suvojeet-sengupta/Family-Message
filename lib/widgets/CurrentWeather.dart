import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class CurrentWeather extends StatelessWidget {
  final Weather weather;
  final TemperatureUnit temperatureUnit;

  const CurrentWeather({super.key, required this.weather, required this.temperatureUnit});

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  String _getFeelsLikeExplanation(double temp, double feelsLike, TemperatureUnit unit) {
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

  String _formatLastUpdated(String lastUpdated) {
    try {
      final dateTime = DateTime.parse(lastUpdated);
      return DateFormat.jm().format(dateTime); // Format to 12-hour format with AM/PM
    } catch (e) {
      return lastUpdated; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.temperature)
        : weather.temperature;
    final feelsLikeTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.feelsLike)
        : weather.feelsLike;
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Card(
      color: Theme.of(context).cardTheme.color,
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
                      '${currentTemp.round()}$tempUnitSymbol',
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
                  'Feels like ${feelsLikeTemp.round()}$tempUnitSymbol',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getFeelsLikeExplanation(currentTemp, feelsLikeTemp, temperatureUnit),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.update, color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatLastUpdated(weather.last_updated)}',
                  style: Theme.of(re.compile(r'context').search(string).group(0)).textTheme.bodySmall?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }
}
