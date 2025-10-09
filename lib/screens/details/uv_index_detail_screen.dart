import 'package:flutter/material.dart';

class UvIndexDetailScreen extends StatelessWidget {
  final double uvIndex;

  const UvIndexDetailScreen({super.key, required this.uvIndex});

  String _getUvIndexDescription() {
    if (uvIndex <= 2) {
      return 'Low';
    } else if (uvIndex <= 5) {
      return 'Moderate';
    } else if (uvIndex <= 7) {
      return 'High';
    } else if (uvIndex <= 10) {
      return 'Very High';
    } else {
      return 'Extreme';
    }
  }

  String _getUvIndexAdvice() {
    if (uvIndex <= 2) {
      return 'No protection needed. You can safely stay outside.';
    } else if (uvIndex <= 5) {
      return 'Protection needed. Seek shade during midday hours, cover up, and use sunscreen.';
    } else if (uvIndex <= 7) {
      return 'Protection essential. Seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    } else if (uvIndex <= 10) {
      return 'Extra protection needed. Avoid being outside during midday hours. Seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    } else {
      return 'Stay inside! Avoid being outside during midday hours. If you must be outside, seek shade, cover up, wear a hat and sunglasses, and use sunscreen.';
    }
  }

  Color _getUvIndexColor() {
    if (uvIndex <= 2) {
      return Colors.green;
    } else if (uvIndex <= 5) {
      return Colors.yellow;
    } else if (uvIndex <= 7) {
      return Colors.orange;
    } else if (uvIndex <= 10) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UV Index'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current UV Index', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  uvIndex.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _getUvIndexDescription(),
                  style: TextStyle(fontSize: 24, color: _getUvIndexColor(), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  _getUvIndexAdvice(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
