import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/weather_service.dart';
import '../widgets/CurrentWeather.dart';
import '../models/weather_model.dart';
import '../widgets/ten_day_forecast.dart';
import '../widgets/weather_detail_card.dart';

import './details/air_quality_detail_screen.dart';
import './details/precipitation_detail_screen.dart';
import './details/pressure_detail_screen.dart';
import './details/sunrise_sunset_detail_screen.dart';


import './details/wind_detail_screen.dart';
import './details/humidity_detail_screen.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Weather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late Weather _weather;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _weather = widget.weather;
  }

  Future<void> _onRefresh() async {
    try {
      final freshWeather = await _weatherService.fetchWeatherByCity(_weather.locationName);
      if (mounted) {
        setState(() {
          _weather = freshWeather;
        });
      }
    } catch (e) {
      // Optionally, show a snackbar or toast on error
      print('Failed to refresh weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isFahrenheit = settingsService.useFahrenheit;

    return Scaffold(
      appBar: AppBar(
        title: Text(_weather.locationName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildWeatherContent(context, isFahrenheit),
    );
  }

  String _getAqiSubtitle(num? aqi) {
    if (aqi == null) return 'N/A';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for sensitive groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Widget _buildWeatherContent(BuildContext context, bool isFahrenheit) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CurrentWeather(weather: _weather, isFahrenheit: isFahrenheit),
          const SizedBox(height: 24),
          TenDayForecast(dailyForecast: _weather.dailyForecast),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrecipitationDetailScreen(precipitation: _weather.dailyForecast.first.totalPrecipMm))),
                child: WeatherDetailCard(
                  title: 'Precipitation',
                  value: '${_weather.dailyForecast.first.totalPrecipMm} mm',
                  subtitle: 'Total rain for the day',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),


              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WindDetailScreen(windSpeedKph: _weather.wind, windDegree: _weather.windDegree, windDir: _weather.windDir))),
                child: WeatherDetailCard(
                  title: 'Wind',
                  value: '${_weather.wind.round()} kph',
                  subtitle: 'From ${_weather.windDir}',
                  icon: Icons.air,
                  color: Colors.green,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressureDetailScreen(pressure: _weather.pressure?.toDouble() ?? 0.0))),
                child: WeatherDetailCard(
                  title: 'Pressure',
                  value: '${_weather.pressure?.round() ?? 'N/A'} hPa',
                  subtitle: 'hPa',
                  icon: Icons.compress,
                  color: Colors.red,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AirQualityDetailScreen(airQuality: _weather.airQuality))),
                child: WeatherDetailCard(
                  title: 'Air Quality',
                  value: _weather.airQuality?.usEpaIndex.round().toString() ?? 'N/A',
                  subtitle: _getAqiSubtitle(_weather.airQuality?.usEpaIndex),
                  icon: Icons.air_outlined,
                  color: Colors.yellow,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HumidityDetailScreen(humidity: _weather.humidity))),
                child: WeatherDetailCard(
                  title: 'Humidity',
                  value: '${_weather.humidity}%',
                  subtitle: 'Current humidity',
                  icon: Icons.water,
                  color: Colors.teal,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SunriseSunsetDetailScreen(sunrise: _weather.dailyForecast.first.sunrise, sunset: _weather.dailyForecast.first.sunset))),
                child: WeatherDetailCard(
                  title: 'Sunrise & Sunset',
                  value: (_weather.dailyForecast.first.sunrise.isNotEmpty && _weather.dailyForecast.first.sunset.isNotEmpty)
                      ? '${_weather.dailyForecast.first.sunrise.substring(11, 16)} am / ${_weather.dailyForecast.first.sunset.substring(11, 16)} pm'
                      : 'N/A',
                  subtitle: 'Sunrise and sunset',
                  icon: Icons.brightness_6,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
