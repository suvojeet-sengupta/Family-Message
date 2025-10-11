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
          const Text('Select your preferred units for weather display.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
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