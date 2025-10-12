import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../screens/weather_detail_screen.dart';
import '../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final TemperatureUnit temperatureUnit;
  final VoidCallback? onTap;
  final bool showDragHandle;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.temperatureUnit,
    this.onTap,
    this.showDragHandle = false,
  });

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  @override
  Widget build(BuildContext context) {
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    final currentTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.temperature)
        : weather.temperature;

    final maxTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.dailyForecast.first.maxTemp)
        : weather.dailyForecast.first.maxTemp;

    final minTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.dailyForecast.first.minTemp)
        : weather.dailyForecast.first.minTemp;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () {
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
              if (showDragHandle)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.drag_handle),
                ),
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
                      '${maxTemp.round()}$tempUnitSymbol ${minTemp.round()}$tempUnitSymbol',
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
                    '${currentTemp.round()}$tempUnitSymbol',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.onSurface,
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