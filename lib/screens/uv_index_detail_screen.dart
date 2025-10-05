import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UvIndexDetailScreen extends StatelessWidget {
  final double uvIndex;

  const UvIndexDetailScreen({super.key, required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UV Index'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentUvIndex(),
            const SizedBox(height: 24),
            _buildUvIndexInfo(),
            const SizedBox(height: 24),
            _buildUvIndexScale(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentUvIndex() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Current UV Index',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            uvIndex.toString(),
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
          ),
          const SizedBox(height: 8),
          Text(
            _getUvIndexCategory(uvIndex),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _getUvIndexColor(uvIndex),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _getUvIndexAdvice(uvIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUvIndexInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is the UV Index?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'The UV Index is an international standard measurement that indicates the strength of sunburn-producing ultraviolet (UV) radiation at a particular place and time. The scale ranges from 0 to 11+, with higher numbers signifying greater UV intensity and increased risk of harm.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildUvIndexScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UV Index Scale',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildScaleItem(1, 2, 'Low', 'Minimal risk. You can safely stay outside with minimal sun protection.', Colors.green),
        _buildScaleItem(3, 5, 'Moderate', 'Moderate risk. Seek shade during midday hours and use SPF 15+ sunscreen.', Colors.yellow),
        _buildScaleItem(6, 7, 'High', 'High risk. Reduce time in the sun between 10 AM and 4 PM and use SPF 50+ sunscreen.', Colors.orange),
        _buildScaleItem(8, 10, 'Very High', 'Very high risk. Minimize sun exposure and take extra precautions.', Colors.red),
        _buildScaleItem(11, null, 'Extreme', 'Extreme risk. Avoid all sun exposure if possible.', Colors.purple),
      ],
    );
  }

  Widget _buildScaleItem(int min, int? max, String category, String advice, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                max == null ? '$min+' : '$min-$max',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(advice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUvIndexCategory(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  Color _getUvIndexColor(double uv) {
    if (uv <= 2) return Colors.green;
    if (uv <= 5) return Colors.yellow;
    if (uv <= 7) return Colors.orange;
    if (uv <= 10) return Colors.red;
    return Colors.purple;
  }

  String _getUvIndexAdvice(double uv) {
    if (uv <= 2) return 'Minimal risk. You can safely stay outside with minimal sun protection.';
    if (uv <= 5) return 'Moderate risk. Seek shade during midday hours and use SPF 15+ sunscreen.';
    if (uv <= 7) return 'High risk. Reduce time in the sun between 10 AM and 4 PM and use SPF 50+ sunscreen.';
    if (uv <= 10) return 'Very high risk. Minimize sun exposure and take extra precautions.';
    return 'Extreme risk. Avoid all sun exposure if possible.';
  }
}
