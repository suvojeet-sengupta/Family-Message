import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math'; // Import for min function
import '../services/settings_service.dart';
import '../services/weather_provider.dart';
import './weather_units_screen.dart';
import './about_screen.dart';
import './saved_locations_screen.dart'; // Import the new screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _buildSectionCard(
            context,
            'General',
            [
              _buildNavigationTile(context, 'Weather Units', 'Temperature, wind, pressure', Icons.straighten, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherUnitsScreen()));
              }),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildNavigationTile(context, 'About', 'App info and credits', Icons.info_outline, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
              }),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildNavigationTile(context, 'Privacy Policy', 'View our privacy policy', Icons.privacy_tip_outlined, () {
                _launchURL('https://suvojeet-sengupta.github.io/Aurora-weather-PrivacyPolicy/');
              }),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            context,
            'Theme',
            [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<SettingsService>(
                  builder: (context, settingsService, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildThemeChoiceButton(context, settingsService, ThemePreference.light, 'Light', Icons.wb_sunny),
                        _buildThemeChoiceButton(context, settingsService, ThemePreference.dark, 'Dark', Icons.nightlight_round),
                        _buildThemeChoiceButton(context, settingsService, ThemePreference.system, 'System', Icons.settings_system_daydream),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            context,
            'Saved Locations',
            [
              if (weatherProvider.savedCities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No saved locations.')),
                )
              else
                ...List.generate(
                  min(weatherProvider.savedCities.length, 3),
                  (index) {
                    final city = weatherProvider.savedCities[index];
                    return ListTile(
                      key: ValueKey(city),
                      leading: const Icon(Icons.drag_handle),
                      title: Text(city),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => weatherProvider.removeCity(city),
                      ),
                    );
                  },
                ),
              if (weatherProvider.savedCities.length > 3)
                Column(
                  children: [
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildNavigationTile(context, 'View All', 'See all saved locations', Icons.arrow_forward, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedLocationsScreen()));
                    }),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildThemeChoiceButton(BuildContext context, SettingsService settingsService, ThemePreference preference, String label, IconData icon) {
    final isSelected = settingsService.themePreference == preference;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => settingsService.setThemePreference(preference),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.6,
        child: Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
            gradient: const LinearGradient(
              colors: [
                Colors.lightBlueAccent,
                Colors.blue,
                Colors.pinkAccent,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}