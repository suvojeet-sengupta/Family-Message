import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/weather_provider.dart';

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
          // Unit Preferences Section
          const Text('Unit Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildUnitSelectionCard<TemperatureUnit>(
            context: context,
            title: 'Temperature Unit',
            currentUnit: settingsService.temperatureUnit,
            units: TemperatureUnit.values,
            onSelected: settingsService.setTemperatureUnit,
            labels: {TemperatureUnit.celsius: 'Celsius', TemperatureUnit.fahrenheit: 'Fahrenheit'},
          ),
          const SizedBox(height: 16),
          _buildUnitSelectionCard<WindSpeedUnit>(
            context: context,
            title: 'Wind Speed Unit',
            currentUnit: settingsService.windSpeedUnit,
            units: WindSpeedUnit.values,
            onSelected: settingsService.setWindSpeedUnit,
            labels: {WindSpeedUnit.kph: 'km/h', WindSpeedUnit.mph: 'mph', WindSpeedUnit.ms: 'm/s'},
          ),
          const SizedBox(height: 16),
          _buildUnitSelectionCard<PressureUnit>(
            context: context,
            title: 'Pressure Unit',
            currentUnit: settingsService.pressureUnit,
            units: PressureUnit.values,
            onSelected: settingsService.setPressureUnit,
            labels: {PressureUnit.hPa: 'hPa', PressureUnit.inHg: 'inHg', PressureUnit.mmHg: 'mmHg'},
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

  Widget _buildUnitSelectionCard<T extends Enum>({
    required BuildContext context,
    required String title,
    required T currentUnit,
    required List<T> units,
    required Function(T) onSelected,
    required Map<T, String> labels,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: units.map((unit) {
                return ChoiceChip(
                  label: Text(labels[unit]!),
                  selected: currentUnit == unit,
                  onSelected: (selected) {
                    if (selected) {
                      onSelected(unit);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: currentUnit == unit
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  side: BorderSide(
                    color: currentUnit == unit
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}