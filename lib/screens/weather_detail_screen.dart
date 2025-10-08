import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_forecast.dart';
import '../models/air_quality.dart';
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
  final Weather? weather;
  final String? locationName;

  const WeatherDetailScreen({super.key, this.weather, this.locationName});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late Weather _weather;
  final WeatherService _weatherService = WeatherService();
  bool _isRefreshing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.weather == null) {
      _isLoading = true;
      _weather = _createPlaceholderWeather();
      _fetchInitialWeather();
    } else {
      _weather = widget.weather!;
      _onRefresh();
    }
  }

  Future<void> _fetchInitialWeather() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final freshWeather = widget.locationName != null
          ? await _weatherService.fetchWeatherByCity(widget.locationName!)
          : await _weatherService.fetchWeather();
      if (mounted) {
        setState(() {
          _weather = freshWeather;
        });
      }
    } catch (e) {
      print('Failed to fetch initial weather: $e');
      if (mounted) {
        setState(() {
          _weather = _createPlaceholderWeather(error: 'Failed to load');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    if(_isLoading) return;
    setState(() {
      _isRefreshing = true;
    });
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
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_weather.locationName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          if (_isRefreshing || _isLoading)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(_isLoading ? 'Fetching weather...' : 'Updating weather...'),
                ],
              ),
            ),
          Expanded(
            child: _buildWeatherContent(context, isFahrenheit),
          ),
        ],
      ),
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

  Widget _buildWeatherContent(BuildContext context, bool isFahrenheit) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CurrentWeather(weather: _weather, isFahrenheit: isFahrenheit),
          const SizedBox(height: 24),
          if (_weather.dailyForecast.isNotEmpty)
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
                onTap: () {
                  if (_weather.dailyForecast.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PrecipitationDetailScreen(precipitation: _weather.dailyForecast.first.totalPrecipMm)));
                  }
                },
                child: WeatherDetailCard(
                  title: 'Precipitation',
                  value: _weather.dailyForecast.isNotEmpty ? '${_weather.dailyForecast.first.totalPrecipMm} mm' : 'N/A',
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
                  subtitle: _weather.windDir.isNotEmpty ? 'From ${_weather.windDir}' : 'N/A',
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
                onTap: () {
                  if (_weather.dailyForecast.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SunriseSunsetDetailScreen(sunrise: _weather.dailyForecast.first.sunrise, sunset: _weather.dailyForecast.first.sunset)));
                  }
                },
                child: WeatherDetailCard(
                  title: 'Sunrise & Sunset',
                  value: (_weather.dailyForecast.isNotEmpty &&
                    _weather.dailyForecast.first.sunrise.isNotEmpty &&
                    _weather.dailyForecast.first.sunset.isNotEmpty
                  ) ? '${_formatTime(_weather.dailyForecast.first.sunrise)} / ${_formatTime(_weather.dailyForecast.first.sunset)}' : 'N/A',
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
