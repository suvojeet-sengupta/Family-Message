import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MoonPhaseDetailScreen extends StatelessWidget {
  final String moonPhase;

  const MoonPhaseDetailScreen({super.key, required this.moonPhase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moon Phase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentMoonPhase(context),
            const SizedBox(height: 24),
            _buildMoonPhaseInfo(context),
            const SizedBox(height: 24),
            _buildMoonPhaseDescription(context),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentMoonPhase(BuildContext context) {
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
              'Current Moon Phase',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _getMoonPhaseIcon(moonPhase, context),
            const SizedBox(height: 16),
            Text(
              moonPhase,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonPhaseInfo(BuildContext context) {
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
              'What is the Moon Phase?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "The moon phase describes the amount of the Moon's surface that is illuminated by the Sun as seen from Earth. It changes cyclically over about 29.5 days.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonPhaseDescription(BuildContext context) {
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
              'About This Phase',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getMoonPhaseDescriptionText(moonPhase),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMoonPhaseIcon(String phase, BuildContext context) {
    IconData iconData;
    switch (phase.toLowerCase()) {
      case 'new moon':
        iconData = Icons.brightness_2_outlined; // Dark moon
        break;
      case 'waxing crescent':
        iconData = Icons.wb_sunny_outlined; // Placeholder, ideally a crescent
        break;
      case 'first quarter':
        iconData = Icons.circle_notifications; // Half moon
        break;
      case 'waxing gibbous':
        iconData = Icons.brightness_4_outlined; // More than half
        break;
      case 'full moon':
        iconData = Icons.brightness_5; // Full moon
        break;
      case 'waning gibbous':
        iconData = Icons.brightness_4; // More than half, opposite side
        break;
      case 'last quarter':
        iconData = Icons.circle_notifications_outlined; // Half moon, opposite side
        break;
      case 'waning crescent':
        iconData = Icons.wb_sunny; // Placeholder, ideally a crescent
        break;
      default:
        iconData = Icons.brightness_2; // Generic moon icon
    }
    return Icon(iconData, size: 80, color: Theme.of(context).colorScheme.primary);
  }

  String _getMoonPhaseDescriptionText(String phase) {
    switch (phase.toLowerCase()) {
      case 'new moon':
        return 'The New Moon is the first lunar phase, when the Moon and Sun have the same ecliptic longitude. At this phase, the Moon is not visible from Earth.';
      case 'waxing crescent':
        return 'The Waxing Crescent is the lunar phase when the Moon is less than half illuminated, and the illuminated part is increasing. It appears as a sliver of light.';
      case 'first quarter':
        return 'The First Quarter Moon is when exactly half of the Moon is illuminated, and the illuminated portion is growing. It rises around noon and sets around midnight.';
      case 'waxing gibbous':
        return 'The Waxing Gibbous is when more than half of the Moon is illuminated, and the illuminated part is still increasing. It appears nearly full.';
      case 'full moon':
        return 'The Full Moon is when the entire face of the Moon is illuminated as seen from Earth. It rises at sunset and sets at sunrise.';
      case 'waning gibbous':
        return 'The Waning Gibbous is when more than half of the Moon is illuminated, but the illuminated part is decreasing. It appears nearly full but shrinking.';
      case 'last quarter':
        return 'The Last Quarter Moon (or Third Quarter) is when exactly half of the Moon is illuminated, and the illuminated portion is decreasing. It rises around midnight and sets around noon.';
      case 'waning crescent':
        return 'The Waning Crescent is the lunar phase when the Moon is less than half illuminated, and the illuminated part is decreasing. It appears as a thin sliver before the New Moon.';
      default:
        return 'Information about this moon phase is not available.';
    }
  }
}