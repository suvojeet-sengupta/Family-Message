import 'package:flutter/material.dart';
import '../widgets/CurrentWeather.dart';
import '../models/weather_model.dart';
import '../widgets/ten_day_forecast.dart';
import '../widgets/weather_detail_card.dart';

import 'package:AuroraWeather/screens/air_quality_detail_screen.dart';
import 'package:AuroraWeather/screens/precipitation_detail_screen.dart';
import 'package:AuroraWeather/screens/pressure_detail_screen.dart';
import 'package:AuroraWeather/screens/sunrise_sunset_detail_screen.dart';
import 'package:AuroraWeather/screens/uv_index_detail_screen.dart';
import 'package:AuroraWeather/screens/visibility_detail_screen.dart';
import 'package:AuroraWeather/screens/wind_detail_screen.dart';
import 'package:AuroraWeather/screens/humidity_detail_screen.dart';

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
      body: _buildWeatherContent(context),
    );
  }

  Widget _buildWeatherContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        CurrentWeather(weather: weather),
        const SizedBox(height: 24),
        TenDayForecast(dailyForecast: weather.dailyForecast),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrecipitationDetailScreen(precipitation: weather.dailyForecast.first.totalPrecipMm))),
              child: WeatherDetailCard(
                title: 'Precipitation',
                value: '${weather.dailyForecast.first.totalPrecipMm} mm',
                subtitle: 'Total rain for the day',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisibilityDetailScreen(visibility: weather.dailyForecast.first.avgVisibilityKm))),
              child: WeatherDetailCard(
                title: 'Visibility',
                value: '${weather.dailyForecast.first.avgVisibilityKm} km',
                subtitle: 'Average visibility',
                icon: Icons.visibility,
                color: Colors.purple,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UvIndexDetailScreen(uvIndex: weather.uvIndex))),
              child: WeatherDetailCard(
                title: 'UV Index',
                value: weather.uvIndex.round().toString(),
                subtitle: 'Low',
                icon: Icons.wb_sunny,
                color: Colors.orange,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WindDetailScreen(windSpeedKph: weather.wind))),
              child: WeatherDetailCard(
                title: 'Wind',
                value: '${weather.wind.round()} kph',
                subtitle: 'From W',
                icon: Icons.air,
                color: Colors.green,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressureDetailScreen(pressure: weather.dailyForecast.first.pressureIn))),
              child: WeatherDetailCard(
                title: 'Pressure',
                value: '${weather.dailyForecast.first.pressureIn} hPa',
                subtitle: 'hPa',
                icon: Icons.compress,
                color: Colors.red,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AirQualityDetailScreen())),
              child: WeatherDetailCard(
                title: 'Air Quality',
                value: '54',
                subtitle: 'Satisfactory',
                icon: Icons.air_outlined,
                color: Colors.yellow,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HumidityDetailScreen(humidity: weather.humidity))),
              child: WeatherDetailCard(
                title: 'Humidity',
                value: '${weather.humidity}%',
                subtitle: 'Dew point ${weather.dailyForecast.first.dewPointC}°',
                icon: Icons.water,
                color: Colors.teal,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SunriseSunsetDetailScreen(sunrise: weather.dailyForecast.first.sunrise, sunset: weather.dailyForecast.first.sunset))),
              child: WeatherDetailCard(
                title: 'Sunrise & Sunset',
                value: (weather.dailyForecast.first.sunrise.isNotEmpty && weather.dailyForecast.first.sunset.isNotEmpty)
                    ? '${weather.dailyForecast.first.sunrise.substring(11, 16)} am / ${weather.dailyForecast.first.sunset.substring(11, 16)} pm'
                    : 'N/A',
                subtitle: 'Sunrise and sunset',
                icon: Icons.brightness_6,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}