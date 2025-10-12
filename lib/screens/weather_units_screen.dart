import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class WeatherUnitsScreen extends StatelessWidget {
  const WeatherUnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Units'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Select your preferred units for weather display.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildUnitSelectionRow<TemperatureUnit>(
            context: context,
            title: 'Temperature Unit',
            icon: Icons.thermostat,
            currentUnit: settingsService.temperatureUnit,
            units: TemperatureUnit.values,
            onSelected: settingsService.setTemperatureUnit,
            labels: {
              TemperatureUnit.celsius: 'Celsius',
              TemperatureUnit.fahrenheit: 'Fahrenheit'
            },
          ),
          _buildUnitSelectionRow<WindSpeedUnit>(
            context: context,
            title: 'Wind Speed Unit',
            icon: Icons.air,
            currentUnit: settingsService.windSpeedUnit,
            units: WindSpeedUnit.values,
            onSelected: settingsService.setWindSpeedUnit,
            labels: {
              WindSpeedUnit.kph: 'km/h',
              WindSpeedUnit.mph: 'mph',
              WindSpeedUnit.ms: 'm/s'
            },
          ),
          _buildUnitSelectionRow<PressureUnit>(
            context: context,
            title: 'Pressure Unit',
            icon: Icons.speed,
            currentUnit: settingsService.pressureUnit,
            units: PressureUnit.values,
            onSelected: settingsService.setPressureUnit,
            labels: {
              PressureUnit.hPa: 'hPa',
              PressureUnit.inHg: 'inHg',
              PressureUnit.mmHg: 'mmHg'
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelectionRow<T extends Enum>({
    required BuildContext context,
    required String title,
    required IconData icon,
    required T currentUnit,
    required List<T> units,
    required Function(T) onSelected,
    required Map<T, String> labels,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labels[currentUnit]!,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _showUnitSelectionDialog(
          context, title, units, currentUnit, onSelected, labels),
    );
  }

  void _showUnitSelectionDialog<T extends Enum>(
    BuildContext context,
    String title,
    List<T> units,
    T currentUnit,
    Function(T) onSelected,
    Map<T, String> labels,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: units.length,
              itemBuilder: (BuildContext context, int index) {
                final unit = units[index];
                return RadioListTile<T>(
                  title: Text(labels[unit]!),
                  value: unit,
                  groupValue: currentUnit,
                  onChanged: (T? value) {
                    if (value != null) {
                      onSelected(value);
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}