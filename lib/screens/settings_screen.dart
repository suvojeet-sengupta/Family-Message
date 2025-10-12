import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/weather_provider.dart';
import './weather_units_screen.dart'; // Import the new screen
import './about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final savedCities = weatherProvider.savedCities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Weather Units Navigation
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Weather Units'),
              subtitle: const Text('Change temperature, wind speed, and pressure units'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherUnitsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Theme Preferences Section
          const Text('Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Consumer<SettingsService>(
            builder: (context, settingsService, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildThemeChoice(context, settingsService, ThemePreference.light, 'Light', Icons.wb_sunny),
                  _buildThemeChoice(context, settingsService, ThemePreference.dark, 'Dark', Icons.nightlight_round),
                  _buildThemeChoice(context, settingsService, ThemePreference.system, 'System', Icons.settings_system_daydream),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Saved Locations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          savedCities.isEmpty
              ? const Center(child: Text('No saved locations.'))
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: savedCities.length,
                  onReorder: (oldIndex, newIndex) {
                    weatherProvider.reorderSavedCities(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final city = savedCities[index];
                    return Card(
                      key: ValueKey(city),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(city),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Delete City?'),
                                  content: Text('Are you sure you want to delete $city?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        // Use the provider to remove the city
                                        Provider.of<WeatherProvider>(context, listen: false).removeCity(city);
                                        Navigator.of(dialogContext).pop(); // Dismiss the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('App information and credits'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChoice(BuildContext context, SettingsService settingsService, ThemePreference preference, String label, IconData icon) {
    final isSelected = settingsService.themePreference == preference;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => settingsService.setThemePreference(preference),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(icon, size: 40, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isSelected ? colorScheme.primary : colorScheme.onSurface)),
        ],
      ),
    );
  }
}