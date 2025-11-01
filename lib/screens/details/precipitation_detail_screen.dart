import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

class PrecipitationDetailScreen extends StatefulWidget {
  final double precipitation;

  const PrecipitationDetailScreen({super.key, required this.precipitation});

  @override
  State<PrecipitationDetailScreen> createState() => _PrecipitationDetailScreenState();
}

class _PrecipitationDetailScreenState extends State<PrecipitationDetailScreen> {
  late double _currentPrecipitation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPrecipitation = widget.precipitation;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        // Simulate real-time precipitation changes
        _currentPrecipitation = (widget.precipitation + (Random().nextDouble() * 5 - 2.5)).clamp(0.0, 50.0);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getPrecipitationIntensity(double value) {
    if (value == 0) {
      return 'None';
    } else if (value < 2.5) {
      return 'Light';
    } else if (value < 7.6) {
      return 'Moderate';
    } else if (value < 50.0) {
      return 'Heavy';
    } else {
      return 'Very Heavy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precipitation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Current Precipitation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentPrecipitation.toStringAsFixed(1)} mm',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          Icon(
                            Icons.water_drop,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 48,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _currentPrecipitation / 50.0, // Assuming max precipitation of 50mm for scale
                        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Intensity: ${_getPrecipitationIntensity(_currentPrecipitation)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Precipitation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Precipitation is any product of the condensation of atmospheric water vapor that falls under gravitational pull from clouds. The main forms of precipitation include drizzle, rain, sleet, snow, ice pellets, graupel and hail.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
