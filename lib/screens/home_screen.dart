import 'package:AuroraWeather/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import '../services/weather_provider.dart';
import '../services/settings_service.dart';
import './settings_screen.dart';
import '../widgets/shimmer_loading.dart';
import './search_screen.dart';
import '../widgets/weather_card.dart';
import '../widgets/friendly_error_display.dart';
import '../screens/details/feels_like_detail_screen.dart';
import '../screens/details/wind_detail_screen.dart';
import '../screens/details/pressure_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final temperatureUnit = settingsService.temperatureUnit;
    final windSpeedUnit = settingsService.windSpeedUnit;
    final pressureUnit = settingsService.pressureUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Weather'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final error = weatherProvider.error;
          if (error != null) {
            // Show a SnackBar if there's an error but we already have some data to display.
            // The full-screen error is handled by _buildWeatherList.
            if (weatherProvider.currentLocationWeather != null || weatherProvider.savedCities.isNotEmpty) {
              weatherProvider.clearError();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    action: SnackBarAction(
                      label: 'RETRY',
                      onPressed: () => Provider.of<WeatherProvider>(context, listen: false).refreshAll(force: true),
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              });
            }
          }
          return _buildWeatherList(context, temperatureUnit, windSpeedUnit, pressureUnit, weatherProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCity(newCity);
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildWeatherList(BuildContext context, TemperatureUnit temperatureUnit, WindSpeedUnit windSpeedUnit, PressureUnit pressureUnit, WeatherProvider weatherProvider) {
    final savedCities = weatherProvider.savedCities;
    final currentLocationWeather = weatherProvider.currentLocationWeather;
    final weatherData = weatherProvider.weatherData;
    final isLoading = weatherProvider.isLoading;
    final error = weatherProvider.error;

    if (error != null && currentLocationWeather == null && savedCities.isEmpty) {
      return FriendlyErrorDisplay(
        message: error,
        onRetry: () => weatherProvider.fetchCurrentLocationWeather(force: true),
      );
    }

    if (savedCities.isEmpty && currentLocationWeather == null && isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching weather...', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    if (savedCities.isEmpty && currentLocationWeather == null && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.cloud_outlined, size: 120, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                Icon(Icons.search, size: 60, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'No cities yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for a city to add it to your list.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                ).then((newCity) {
                  if (newCity != null && newCity.isNotEmpty) {
                    Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCity(newCity);
                  }
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Search City'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => weatherProvider.refreshAll(),
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (currentLocationWeather != null) ...[
            const Row(
              children: [
                Icon(Icons.location_on_outlined),
                SizedBox(width: 8),
                Text('Current location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            WeatherCard(
              weather: currentLocationWeather,
              temperatureUnit: temperatureUnit,
              isOffline: weatherProvider.isOffline,
              lastUpdated: DateTime.fromMillisecondsSinceEpoch(currentLocationWeather.timestamp),
            ),
          ],
          if (currentLocationWeather != null && savedCities.isNotEmpty)
            const SizedBox(height: 24),
          if (savedCities.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.bookmark_border),
                SizedBox(width: 8),
                Text('Saved locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedCities.length,
              onReorder: (oldIndex, newIndex) {
                weatherProvider.reorderSavedCities(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final city = savedCities[index];
                final weather = weatherData[city];
                if (weather == null) {
                  return ShimmerLoading(key: ValueKey(city));
                }
                return Dismissible(
                  key: ValueKey(city),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    Provider.of<WeatherProvider>(context, listen: false).removeCity(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$city removed')),
                    );
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text("Are you sure you wish to delete this item?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: WeatherCard(
                    weather: weather,
                    temperatureUnit: temperatureUnit,
                    showDragHandle: true,
                    isOffline: weatherProvider.isOffline,
                    lastUpdated: DateTime.fromMillisecondsSinceEpoch(weather.timestamp),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // Helper to build weather cards for current location and saved cities
  Widget _buildWeatherCard(BuildContext context, Weather weather, TemperatureUnit temperatureUnit, WindSpeedUnit windSpeedUnit, PressureUnit pressureUnit, bool isOffline) {
    return WeatherCard(
      weather: weather,
      temperatureUnit: temperatureUnit,
      isOffline: isOffline,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(weather.timestamp),
      onTap: () {
        // Navigate to detail screen based on weather parameter
        // Example for FeelsLikeDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeelsLikeDetailScreen(
              feelsLike: weather.feelsLike,
              temperatureUnit: temperatureUnit,
            ),
          ),
        );
      },
      // Add more detail screen navigations here as needed
    );
  }
}