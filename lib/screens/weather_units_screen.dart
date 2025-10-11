
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class WeatherUnitsScreen extends StatefulWidget {
  const WeatherUnitsScreen({super.key});

  @override
  State<WeatherUnitsScreen> createState() => _WeatherUnitsScreenState();
}

class _WeatherUnitsScreenState extends State<WeatherUnitsScreen> {
  String? _expandedTile;

  void _handleExpansion(String tile) {
    setState(() {
      if (_expandedTile == tile) {
        _expandedTile = null;
      } else {
        _expandedTile = tile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final theme = Theme.of(context);

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
              }
            },
            isExpanded: _expandedTile == 'temperature',
            onExpansionChanged: () => _handleExpansion('temperature'),
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
              }
            },
            isExpanded: _expandedTile == 'wind',
            onExpansionChanged: () => _handleExpansion('wind'),
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
              }
            },
            isExpanded: _expandedTile == 'pressure',
            onExpansionChanged: () => _handleExpansion('pressure'),
          ),
          const SizedBox(height: 16),
          _buildUnitSelectionCard(
            context: context,
            title: 'Precipitation',
            currentValue: settingsService.precipitationUnit.toString().split('.').last,
            options: PrecipitationUnit.values,
            groupValue: settingsService.precipitationUnit,
            onChanged: (value) {
              if (value != null) {
                settingsService.setPrecipitationUnit(value as PrecipitationUnit);
              }
            },
            isExpanded: _expandedTile == 'precipitation',
            onExpansionChanged: () => _handleExpansion('precipitation'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelectionCard<T>({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<T> options,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required bool isExpanded,
    required VoidCallback onExpansionChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key(title),
            title: Text(title, style: theme.textTheme.titleLarge),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentValue,
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onExpansionChanged: (_) => onExpansionChanged(),
            initiallyExpanded: isExpanded,
            children: options.map((option) {
              return RadioListTile<T>(
                title: Text(option.toString().split('.').last),
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
