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
          _buildUnitSelectionCard(
            context: context,
            title: 'Temperature',
            currentValue: settingsService.temperatureUnit.toString().split('.').last,
            options: TemperatureUnit.values,
            groupValue: settingsService.temperatureUnit,
            onChanged: (value) {
              if (value != null) {
                settingsService.setTemperatureUnit(value as TemperatureUnit);
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 16),
          _buildUnitSelectionCard(
            context: context,
            title: 'Wind Speed',
            currentValue: settingsService.windSpeedUnit.toString().split('.').last,
            options: WindSpeedUnit.values,
            groupValue: settingsService.windSpeedUnit,
            onChanged: (value) {
              if (value != null) {
                settingsService.setWindSpeedUnit(value as WindSpeedUnit);
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 16),
          _buildUnitSelectionCard(
            context: context,
            title: 'Pressure',
            currentValue: settingsService.pressureUnit.toString().split('.').last,
            options: PressureUnit.values,
            groupValue: settingsService.pressureUnit,
            onChanged: (value) {
              if (value != null) {
                settingsService.setPressureUnit(value as PressureUnit);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showUnitSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = options[index];
                return RadioListTile<T>(
                  title: Text(option.toString().split('.').last),
                  value: option,
                  groupValue: groupValue,
                  onChanged: onChanged,
                );
              },
            ),
          ),
          actions: <Widget>[
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

  Widget _buildUnitSelectionCard<T>({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<T> options,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleLarge),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentValue,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        onTap: () {
          _showUnitSelectionDialog(
            context: context,
            title: title,
            options: options,
            groupValue: groupValue,
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}