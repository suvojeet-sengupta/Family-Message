import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:AuroraWeather/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/daily_forecast.dart';
import '../models/air_quality.dart';
import '../services/settings_service.dart';
import '../services/weather_provider.dart';
import '../widgets/CurrentWeather.dart';
import '../models/weather_model.dart';
import '../widgets/ten_day_forecast.dart';
import '../widgets/weather_detail_card.dart';
import '../widgets/shareable_weather_widget.dart';

import './details/air_quality_detail_screen.dart';
import './details/precipitation_detail_screen.dart';
import './details/pressure_detail_screen.dart';
import './details/sunrise_sunset_detail_screen.dart';
import './details/visibility_detail_screen.dart';
import './details/dew_point_detail_screen.dart';
import './details/uv_index_detail_screen.dart';

import '../constants/detail_card_constants.dart'; // New import
import 'package:reorderable_grid_view/reorderable_grid_view.dart'; // New import

import './details/wind_detail_screen.dart';
import './details/humidity_detail_screen.dart';
import 'package:AuroraWeather/widgets/friendly_error_display.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Weather? weather;
  const WeatherDetailScreen({super.key, this.weather});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _shareWeatherDetails(Weather weatherToShare) async {
    RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      // Fallback to screenshotController if boundary is null
      final imageFile = await screenshotController.captureAndSave(
        (await getTemporaryDirectory()).path,
        fileName: "aurora_weather_share.png",
      );
      if (imageFile != null) {
        await Share.shareXFiles([XFile(imageFile)], text: 'Check out the weather in ${weatherToShare.locationName} with Aurora Weather!');
      }
      return;
    }

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/aurora_weather_share.png';
      final file = File(imagePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(imagePath)], text: 'Check out the weather in ${weatherToShare.locationName} with Aurora Weather!');
    }
  }

  String _formatTime(String date, String time) {
    if (time.isEmpty || date.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $time");
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  double _kphToMph(double kph) {
    return kph * 0.621371;
  }

  double _kphToMs(double kph) {
    return kph * 1000 / 3600;
  }

  double _hPaToInHg(double hPa) {
    return hPa * 0.02953;
  }

  double _hPaToMmHg(double hPa) {
    return hPa * 0.750062;
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final temperatureUnit = settingsService.temperatureUnit;
    final windSpeedUnit = settingsService.windSpeedUnit;
    final pressureUnit = settingsService.pressureUnit;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weatherToDisplay = widget.weather ?? weatherProvider.currentLocationWeather;
        final isLoading = weatherProvider.isLoading;
        final error = weatherProvider.error;

        if (error != null && weatherToDisplay == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: FriendlyErrorDisplay(
              message: error,
              onRetry: () {
                if (widget.weather == null) {
                  weatherProvider.fetchCurrentLocationWeather(force: true);
                } else {
                  weatherProvider.fetchWeatherForCity(widget.weather!.locationName, force: true);
                }
              },
            ),
          );
        }

        if (weatherToDisplay == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Temperature conversion for display
        final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';
        final dewPointDisplay = temperatureUnit == TemperatureUnit.fahrenheit
            ? _celsiusToFahrenheit(weatherToDisplay.dewpoint_c)
            : weatherToDisplay.dewpoint_c;

        // Wind speed conversion for display
        double windSpeedDisplay;
        String windSpeedSymbol;
        switch (windSpeedUnit) {
          case WindSpeedUnit.mph:
            windSpeedDisplay = _kphToMph(weatherToDisplay.wind);
            windSpeedSymbol = 'mph';
            break;
          case WindSpeedUnit.ms:
            windSpeedDisplay = _kphToMs(weatherToDisplay.wind);
            windSpeedSymbol = 'm/s';
            break;
          case WindSpeedUnit.kph:
          default:
            windSpeedDisplay = weatherToDisplay.wind;
            windSpeedSymbol = 'km/h';
            break;
        }

        // Pressure conversion for display
        double pressureDisplay;
        String pressureSymbol;
        switch (pressureUnit) {
          case PressureUnit.inHg:
            pressureDisplay = _hPaToInHg(weatherToDisplay.pressure?.toDouble() ?? 0.0);
            pressureSymbol = 'inHg';
            break;
          case PressureUnit.mmHg:
            pressureDisplay = _hPaToMmHg(weatherToDisplay.pressure?.toDouble() ?? 0.0);
            pressureSymbol = 'mmHg';
            break;
          case PressureUnit.hPa:
          default:
            pressureDisplay = weatherToDisplay.pressure?.toDouble() ?? 0.0;
            pressureSymbol = 'hPa';
            break;
        }

        return WillPopScope(
          onWillPop: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              title: Text(weatherToDisplay.locationName),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareWeatherDetails(weatherToDisplay),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
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
                      child: _buildWeatherContent(context, weatherToDisplay, weatherProvider, temperatureUnit, windSpeedUnit, pressureUnit, tempUnitSymbol, windSpeedDisplay, windSpeedSymbol, pressureDisplay, pressureSymbol, dewPointDisplay),
                    ),
                  ],
                ),
                // Hidden widget for screenshot
                Positioned(
                  left: -10000, // Position off-screen
                  top: -10000,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: ShareableWeatherWidget(weather: weatherToDisplay),
                  ),
                ),
              ],
            ),
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

  String _getUvIndexDescription(double uvIndex) {
    if (uvIndex <= 2) {
      return 'Low';
    } else if (uvIndex <= 5) {
      return 'Moderate';
    } else if (uvIndex <= 7) {
      return 'High';
    } else if (uvIndex <= 10) {
      return 'Very High';
    } else {
      return 'Extreme';
    }
  }

  Widget _buildHighLowForecast(BuildContext context, DailyForecast forecast, TemperatureUnit temperatureUnit, String currentCondition) {
    final highTemp = temperatureUnit == TemperatureUnit.fahrenheit ? forecast.maxTempF : forecast.maxTemp;
    final lowTemp = temperatureUnit == TemperatureUnit.fahrenheit ? forecast.minTempF : forecast.minTemp;
    final tempUnitSymbol = temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('High', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text('${highTemp.round()}$tempUnitSymbol', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Column(
              children: [
                Text('Low', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text('${lowTemp.round()}$tempUnitSymbol', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Column(
              children: [
                Text('Condition', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text(currentCondition, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center,),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, Weather weather, WeatherProvider weatherProvider, TemperatureUnit temperatureUnit, WindSpeedUnit windSpeedUnit, PressureUnit pressureUnit, String tempUnitSymbol, double windSpeedDisplay, String windSpeedSymbol, double pressureDisplay, String pressureSymbol, double dewPointDisplay) {
    String _calculateDaylight(String date, String sunrise, String sunset) {
      if (sunrise.isEmpty || sunset.isEmpty || date.isEmpty) {
        return 'N/A';
      }
      try {
        final sunriseTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunrise");
        final sunsetTime = DateFormat("yyyy-MM-dd h:mm a").parse("$date $sunset");
        final duration = sunsetTime.difference(sunriseTime);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        return '$hours hr $minutes min';
      } catch (e) {
        return 'N/A';
      }
    }

    return RefreshIndicator(
      onRefresh: () => widget.weather == null ? weatherProvider.fetchCurrentLocationWeather(force: false) : weatherProvider.fetchWeatherForCity(widget.weather!.locationName, force: false),
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CurrentWeather(weather: weather, temperatureUnit: temperatureUnit),
          const SizedBox(height: 16),
          if (weather.dailyForecast.isNotEmpty)
            _buildHighLowForecast(context, weather.dailyForecast.first, temperatureUnit, weather.condition),
          const SizedBox(height: 24),
          if (weather.dailyForecast.isNotEmpty)
            TenDayForecast(dailyForecast: weather.dailyForecast, temperatureUnit: temperatureUnit),
          const SizedBox(height: 24),
          Consumer<SettingsService>(
            builder: (context, settingsService, child) {
              final visibleCards = settingsService.detailCardPreferences
                  .where((card) => card.isVisible)
                  .toList();

              if (visibleCards.isEmpty) {
                return const SizedBox.shrink(); // Or a message indicating no cards are visible
              }

              return ReorderableGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                onReorder: (oldIndex, newIndex) {
                  settingsService.reorderDetailCards(oldIndex, newIndex);
                },
                children: visibleCards.map((card) {
                  switch (card.cardTypeId) {
                    case 'precipitation':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
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
                      );
                    case 'wind':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WindDetailScreen(windSpeedKphRaw: weather.wind, windDegree: weather.windDegree, windDir: weather.windDir, windSpeedUnit: windSpeedUnit))),
                        child: WeatherDetailCard(
                          title: 'Wind',
                          value: '${windSpeedDisplay.round()} $windSpeedSymbol',
                          subtitle: weather.windDir.isNotEmpty ? 'From ${weather.windDir}' : 'N/A',
                          icon: Icons.air,
                          color: Colors.green,
                        ),
                      );
                    case 'pressure':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressureDetailScreen(pressure: weather.pressure?.toDouble() ?? 0.0, pressureUnit: pressureUnit))),
                        child: WeatherDetailCard(
                          title: 'Pressure',
                          value: '${pressureDisplay.round()} $pressureSymbol',
                          subtitle: pressureSymbol,
                          icon: Icons.compress,
                          color: Colors.red,
                        ),
                      );
                    case 'air_quality':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AirQualityDetailScreen(airQuality: weather.airQuality))),
                        child: WeatherDetailCard(
                          title: 'Air Quality',
                          value: weather.airQuality?.usEpaIndex.round().toString() ?? 'N/A',
                          subtitle: _getAqiSubtitle(weather.airQuality?.usEpaIndex),
                          icon: Icons.air_outlined,
                          color: Colors.yellow,
                        ),
                      );
                    case 'humidity':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HumidityDetailScreen(humidity: weather.humidity))),
                        child: WeatherDetailCard(
                          title: 'Humidity',
                          value: '${weather.humidity}%',
                          subtitle: 'Current humidity',
                          icon: Icons.water,
                          color: Colors.teal,
                        ),
                      );
                    case 'uv_index':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UvIndexDetailScreen(weather: weather))),
                        child: WeatherDetailCard(
                          title: 'UV Index',
                          value: weather.uvIndex.round().toString(),
                          subtitle: _getUvIndexDescription(weather.uvIndex),
                          icon: Icons.wb_sunny_outlined,
                          color: Colors.orange,
                        ),
                      );
                    case 'sunrise_sunset':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () {
                          if (weather.dailyForecast.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SunriseSunsetDetailScreen(date: weather.dailyForecast.first.date, sunrise: weather.dailyForecast.first.sunrise, sunset: weather.dailyForecast.first.sunset)));
                          }
                        },
                        child: WeatherDetailCard(
                          title: 'Sunrise & Sunset',
                          value: (weather.dailyForecast.isNotEmpty &&
                            weather.dailyForecast.first.sunrise.isNotEmpty &&
                            weather.dailyForecast.first.sunset.isNotEmpty
                          ) ? '${_formatTime(weather.dailyForecast.first.date, weather.dailyForecast.first.sunrise)} / ${_formatTime(weather.dailyForecast.first.date, weather.dailyForecast.first.sunset)}' : 'N/A',
                          subtitle: 'Daylight: ${_calculateDaylight(weather.dailyForecast.first.date, weather.dailyForecast.first.sunrise, weather.dailyForecast.first.sunset)}',
                          icon: Icons.brightness_6,
                          color: Colors.amber,
                        ),
                      );
                    case 'visibility':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisibilityDetailScreen(visKm: weather.vis_km, visMiles: weather.vis_miles))),
                        child: WeatherDetailCard(
                          title: 'Visibility',
                          value: '${weather.vis_km} km',
                          subtitle: 'Clear conditions',
                          icon: Icons.visibility,
                          color: Colors.purple,
                        ),
                      );
                    case 'dew_point':
                      return InkWell(
                        key: ValueKey(card.cardTypeId), // Unique key for reordering
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DewPointDetailScreen(dewPoint: weather.dewpoint_c, temperatureUnit: temperatureUnit))),
                        child: WeatherDetailCard(
                          title: 'Dew Point',
                          value: '${dewPointDisplay.round()}$tempUnitSymbol',
                          subtitle: 'Comfort level',
                          icon: Icons.thermostat_auto,
                          color: Colors.lightBlue,
                        ),
                      );
                    default:
                      return const SizedBox.shrink(); // Should not happen if defaultDetailCards is kept in sync
                  }
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}