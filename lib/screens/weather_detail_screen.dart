import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/ten_day_forecast.dart';
import '../widgets/weather_detail_card.dart';

class WeatherDetailScreen extends StatelessWidget {
  final Weather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TenDayForecast(dailyForecast: weather.dailyForecast),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            WeatherDetailCard(
              title: 'Precipitation',
              value: '${weather.dailyForecast.first.totalPrecipMm} mm',
              subtitle: 'Total rain for the day',
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            WeatherDetailCard(
              title: 'Visibility',
              value: '${weather.dailyForecast.first.avgVisibilityKm} km',
              subtitle: 'Average visibility',
              icon: Icons.visibility,
              color: Colors.purple,
            ),
            WeatherDetailCard(
              title: 'UV Index',
              value: weather.uvIndex.round().toString(),
              subtitle: 'Low',
              icon: Icons.wb_sunny,
              color: Colors.orange,
            ),
            WeatherDetailCard(
              title: 'Wind',
              value: '${weather.wind.round()} kph',
              subtitle: 'From W',
              icon: Icons.air,
              color: Colors.green,
            ),
            WeatherDetailCard(
              title: 'Pressure',
              value: '${weather.dailyForecast.first.pressureIn} hPa',
              subtitle: 'hPa',
              icon: Icons.compress,
              color: Colors.red,
            ),
            WeatherDetailCard(
              title: 'Air Quality',
              value: '54',
              subtitle: 'Satisfactory',
              icon: Icons.air_outlined,
              color: Colors.yellow,
            ),
            WeatherDetailCard(
              title: 'Humidity',
              value: '${weather.humidity}%',
              subtitle: 'Dew point ${weather.dailyForecast.first.dewPointC}°',
              icon: Icons.water,
              color: Colors.teal,
            ),
            WeatherDetailCard(
              title: 'Sunrise & Sunset',
              value: (weather.dailyForecast.first.sunrise.isNotEmpty && weather.dailyForecast.first.sunset.isNotEmpty)
                  ? '${weather.dailyForecast.first.sunrise.substring(11, 16)} am / ${weather.dailyForecast.first.sunset.substring(11, 16)} pm'
                  : 'N/A',
              subtitle: 'Sunrise and sunset',
              icon: Icons.brightness_6,
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
}