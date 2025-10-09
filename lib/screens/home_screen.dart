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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isFahrenheit = settingsService.useFahrenheit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora Weather'),
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
          return _buildWeatherList(context, isFahrenheit, weatherProvider);
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

  Widget _buildWeatherList(BuildContext context, bool isFahrenheit, WeatherProvider weatherProvider) {
    final savedCities = weatherProvider.savedCities;
    final currentLocationWeather = weatherProvider.currentLocationWeather;
    final weatherData = weatherProvider.weatherData;
    final isLoading = weatherProvider.isLoading;

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
                Icon(Icons.cloud_outlined, size: 120, color: Colors.white.withOpacity(0.1)),
                Icon(Icons.search, size: 60, color: Colors.white.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'No cities yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for a city to add it to your list.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
                foregroundColor: Colors.black, backgroundColor: Colors.white,
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
      color: Colors.amber,
      backgroundColor: Colors.grey[900],
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
            WeatherCard(weather: currentLocationWeather, isFahrenheit: isFahrenheit),
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
            ...savedCities.map((city) {
              final weather = weatherData[city];
              if (weather == null) {
                return const ShimmerLoading();
              }
              return WeatherCard(weather: weather, isFahrenheit: isFahrenheit);
            }).toList(),
          ],
        ],
      ),
    );
  }
}