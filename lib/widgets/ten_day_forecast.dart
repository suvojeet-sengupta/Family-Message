import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class TenDayForecast extends StatelessWidget {
  final List<DailyForecast> dailyForecast;
  final TemperatureUnit temperatureUnit;

  const TenDayForecast({super.key, required this.dailyForecast, required this.temperatureUnit});

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  @override
  Widget build(BuildContext context) {
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dailyForecast.length}-day forecast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyForecast.length,
                itemBuilder: (context, index) {
                  final day = dailyForecast[index];
                  final displayMaxTemp = temperatureUnit == TemperatureUnit.fahrenheit
                      ? _celsiusToFahrenheit(day.maxTemp)
                      : day.maxTemp;
                  final displayMinTemp = temperatureUnit == TemperatureUnit.fahrenheit
                      ? _celsiusToFahrenheit(day.minTemp)
                      : day.minTemp;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(DateTime.parse(day.date)),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(DateFormat('MM/dd').format(DateTime.parse(day.date)), style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        (day.iconUrl.startsWith('https://cdn.weatherapi.com')
                            ? Image.network(
                                day.iconUrl,
                                height: 40,
                                width: 40,
                              )
                            : const SizedBox(
                                height: 40,
                                width: 40,
                              )),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${displayMaxTemp.round()}$tempUnitSymbol / ${displayMinTemp.round()}$tempUnitSymbol', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
