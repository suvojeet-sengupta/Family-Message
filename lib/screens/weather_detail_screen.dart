import 'package:AuroraWeather/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_forecast.dart';
import '../models/air_quality.dart';
import '../services/settings_service.dart';
import '../services/weather_provider.dart';
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

class WeatherDetailScreen extends StatelessWidget {
  final Weather? weather;
  const WeatherDetailScreen({super.key, this.weather});

  Weather _createPlaceholderWeather({String? error}) {
    return Weather(
      locationName: error ?? 'Loading...',
      temperature: 0,
      temperatureF: 0,
      condition: 'N/A',
      conditionCode: 0,
      iconUrl: '',
      feelsLike: 0,
      feelsLikeF: 0,
      wind: 0,
      windDir: 'N/A',
      windDegree: 0,
      humidity: 0,
      airQuality: AirQuality(usEpaIndex: 0),
      pressure: 0,
      hourlyForecast: [],
      dailyForecast: [
        DailyForecast(
          date: '',
          maxTemp: 0,
          maxTempF: 0,
          minTemp: 0,
          minTempF: 0,
          iconUrl: '',
          condition: 'N/A',
          hourlyForecast: [],
          totalPrecipMm: 0,
          avgHumidity: 0,
          maxWindKph: 0,
          sunrise: '',
          sunset: '',
          moonPhase: '',
        )
      ],
      timestamp: 0,
    );
  }

  String _formatTime(String time) {
    if (time.isEmpty) {
      return 'N/A';
    }
    final dateTime = DateTime.parse(time);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isFahrenheit = settingsService.useFahrenheit;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weatherToDisplay = weather ?? weatherProvider.currentLocationWeather ?? _createPlaceholderWeather(error: weatherProvider.error);
        final isLoading = weatherProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            title: Text(weatherToDisplay.locationName),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black.withOpacity(0.5),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Text('Fetching weather...'),
                    ],
                  ),
                ),
              Expanded(
                child: _buildWeatherContent(context, isFahrenheit, weatherToDisplay, weatherProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAqiSubtitle(num? aqi) {
    if (aqi == null || aqi == 0) return 'N/A';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for sensitive groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Widget _buildWeatherContent(BuildContext context, bool isFahrenheit, Weather weather, WeatherProvider weatherProvider) {
    return RefreshIndicator(
      onRefresh: () => this.weather == null ? weatherProvider.fetchCurrentLocationWeather(force: true) : weatherProvider.fetchWeatherForCity(weather.locationName, force: true),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CurrentWeather(weather: weather, isFahrenheit: isFahrenheit),
          const SizedBox(height: 24),
          if (weather.dailyForecast.isNotEmpty)
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
                onTap: () {
                  if (weather.dailyForecast.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PrecipitationDetailScreen(precipitation: weather.dailyForecast.first.totalPrecipMm)));
                  }
                },
                child: WeatherDetailCard(
                  title: 'Precipitation',
                  value: weather.dailyForecast.isNotEmpty ? '${weather.dailyForecast.first.totalPrecipMm} mm' : 'N/A',
                  subtitle: 'Total rain for the day',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),


              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WindDetailScreen(windSpeedKph: weather.wind, windDegree: weather.windDegree, windDir: weather.windDir))),
                child: WeatherDetailCard(
                  title: 'Wind',
                  value: '${weather.wind.round()} kph',
                  subtitle: weather.windDir.isNotEmpty ? 'From ${weather.windDir}' : 'N/A',
                  icon: Icons.air,
                  color: Colors.green,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressureDetailScreen(pressure: weather.pressure?.toDouble() ?? 0.0))),
                child: WeatherDetailCard(
                  title: 'Pressure',
                  value: '${weather.pressure?.round() ?? 'N/A'} hPa',
                  subtitle: 'hPa',
                  icon: Icons.compress,
                  color: Colors.red,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AirQualityDetailScreen(airQuality: weather.airQuality))),
                child: WeatherDetailCard(
                  title: 'Air Quality',
                  value: weather.airQuality?.usEpaIndex.round().toString() ?? 'N/A',
                  subtitle: _getAqiSubtitle(weather.airQuality?.usEpaIndex),
                  icon: Icons.air_outlined,
                  color: Colors.yellow,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HumidityDetailScreen(humidity: weather.humidity))),
                child: WeatherDetailCard(
                  title: 'Humidity',
                  value: '${weather.humidity}%',
                  subtitle: 'Current humidity',
                  icon: Icons.water,
                  color: Colors.teal,
                ),
              ),
              InkWell(
                onTap: () {
                  if (weather.dailyForecast.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SunriseSunsetDetailScreen(sunrise: weather.dailyForecast.first.sunrise, sunset: weather.dailyForecast.first.sunset)));
                  }
                },
                child: WeatherDetailCard(
                  title: 'Sunrise & Sunset',
                  value: (weather.dailyForecast.isNotEmpty &&
                    weather.dailyForecast.first.sunrise.isNotEmpty &&
                    weather.dailyForecast.first.sunset.isNotEmpty
                  ) ? '${_formatTime(weather.dailyForecast.first.sunrise)} / ${_formatTime(weather.dailyForecast.first.sunset)}' : 'N/A',
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
