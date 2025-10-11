import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/details/feels_like_detail_screen.dart';
import '../screens/details/wind_detail_screen.dart';
import '../screens/details/humidity_detail_screen.dart';
import '../screens/details/uv_index_detail_screen.dart';
import '../services/settings_service.dart';

class WeatherInfo extends StatelessWidget {
  final Weather weather;

  const WeatherInfo({super.key, required this.weather});

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  double _kphToMph(double kph) {
    return kph * 0.621371;
  }

  double _kphToMs(double kph) {
    return kph * 1000 / 3600;
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
    final settingsService = Provider.of<SettingsService>(context);
    final temperatureUnit = settingsService.temperatureUnit;
    final windSpeedUnit = settingsService.windSpeedUnit;

    // Temperature conversion
    final feelsLikeTemp = temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(weather.feelsLike)
        : weather.feelsLike;
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    // Wind speed conversion
    double windSpeed;
    String windSpeedSymbol;
    switch (windSpeedUnit) {
      case WindSpeedUnit.mph:
        windSpeed = _kphToMph(weather.wind);
        windSpeedSymbol = 'mph';
        break;
      case WindSpeedUnit.ms:
        windSpeed = _kphToMs(weather.wind);
        windSpeedSymbol = 'm/s';
        break;
      case WindSpeedUnit.kph:
      default:
        windSpeed = weather.wind;
        windSpeedSymbol = 'km/h';
        break;
    }

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
                      _createFadeRoute(FeelsLikeDetailScreen(
                        feelsLike: feelsLikeTemp,
                        temperatureUnit: temperatureUnit,
                      )),
                    );
                  },
                  child: _buildInfoItem(Icons.thermostat, 'Feels Like', '${feelsLikeTemp.round()}$tempUnitSymbol'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      _createFadeRoute(WindDetailScreen(
                        windSpeed: windSpeed,
                        windSpeedUnit: windSpeedUnit,
                      )),
                    );
                  },
                  child: _buildInfoItem(Icons.air, 'Wind', '${windSpeed.round()} $windSpeedSymbol'),
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
                      _createFadeRoute(HumidityDetailScreen(humidity: weather.humidity)),
                    );
                  },
                  child: _buildInfoItem(Icons.water_drop, 'Humidity', '${weather.humidity}%'),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      _createFadeRoute(UvIndexDetailScreen(uvIndex: weather.uvIndex)),
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