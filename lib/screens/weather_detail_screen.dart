import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/CurrentWeather.dart';
import '../widgets/WeatherInfo.dart';
import '../widgets/HourlyForecast.dart';
import '../widgets/DailyForecast.dart';

class WeatherDetailScreen extends StatelessWidget {
  final Weather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2F33),
      appBar: AppBar(
        title: Text(weather.locationName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildWeatherContent(),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CurrentWeather(weather: weather),
            const SizedBox(height: 24),
            WeatherInfo(weather: weather),
            const SizedBox(height: 24),
            HourlyForecastWidget(hourlyForecast: weather.hourlyForecast),
            const SizedBox(height: 24),
            DailyForecastWidget(dailyForecast: weather.dailyForecast),
          ],
        ),
      ),
    );
  }
}
