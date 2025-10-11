import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_service.dart'; // Import SettingsService for PressureUnit

class PressureDetailScreen extends StatelessWidget {
  final double pressure;
  final PressureUnit pressureUnit;

  const PressureDetailScreen({super.key, required this.pressure, required this.pressureUnit});

  double _hPaToInHg(double hPa) {
    return hPa * 0.02953;
  }

  double _hPaToMmHg(double hPa) {
    return hPa * 0.750062;
  }

  @override
  Widget build(BuildContext context) {
    double displayPressure;
    String displayPressureSymbol;

    switch (pressureUnit) {
      case PressureUnit.inHg:
        displayPressure = _hPaToInHg(pressure);
        displayPressureSymbol = 'inHg';
        break;
      case PressureUnit.mmHg:
        displayPressure = _hPaToMmHg(pressure);
        displayPressureSymbol = 'mmHg';
        break;
      case PressureUnit.hPa:
      default:
        displayPressure = pressure;
        displayPressureSymbol = 'hPa';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pressure'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentPressure(context, displayPressure, displayPressureSymbol),
            const SizedBox(height: 24),
            _buildPressureInfo(context),
            const SizedBox(height: 24),
            _buildAdvice(context, displayPressure),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentPressure(BuildContext context, double displayPressure, String displayPressureSymbol) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Current Pressure',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed, size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${displayPressure.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayPressureSymbol,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Atmospheric Pressure?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Atmospheric pressure is the pressure exerted by the weight of the atmosphere. It is a crucial factor in weather forecasting.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildAdvice(BuildContext context, double displayPressure) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Indication',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getPressureAdvice(displayPressure),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _getPressureAdvice(double pressure) {
    // Convert to hPa for advice logic, as the advice thresholds are likely based on hPa.
    double pressureHPa;
    switch (pressureUnit) {
      case PressureUnit.inHg:
        pressureHPa = pressure / 0.02953;
        break;
      case PressureUnit.mmHg:
        pressureHPa = pressure / 0.750062;
        break;
      case PressureUnit.hPa:
      default:
        pressureHPa = pressure;
        break;
    }

    if (pressureHPa > 1020) {
      return 'High pressure is currently dominant. Expect stable conditions with clear skies and light winds. A good day for outdoor activities.';
    } else if (pressureHPa < 1000) {
      return 'Low pressure is influencing the weather. This often brings unsettled conditions like clouds, rain, or wind. Be prepared for changing weather.';
    } else {
      return 'The atmospheric pressure is in a neutral range. Weather conditions are likely to be stable, but keep an eye on the forecast for any changes.';
    }
  }
}