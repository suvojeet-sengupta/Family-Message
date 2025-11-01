import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class AirQualityDetailScreen extends StatefulWidget {
  final AirQuality? airQuality;

  const AirQualityDetailScreen({super.key, this.airQuality});

  @override
  State<AirQualityDetailScreen> createState() => _AirQualityDetailScreenState();
}

class _AirQualityDetailScreenState extends State<AirQualityDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _aqiAnimation;
  num _currentAqi = 0;

  @override
  void initState() {
    super.initState();
    _currentAqi = widget.airQuality?.usEpaIndex ?? 0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _aqiAnimation = Tween<double>(begin: 0, end: _currentAqi.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.airQuality != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AirQualityDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.airQuality?.usEpaIndex != widget.airQuality?.usEpaIndex) {
      _currentAqi = widget.airQuality?.usEpaIndex ?? 0;
      _aqiAnimation = Tween<double>(begin: oldWidget.airQuality?.usEpaIndex?.toDouble() ?? 0, end: _currentAqi.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color aqiColor = _getAqiColor(context, widget.airQuality?.usEpaIndex);
    final Color cardBackgroundColor = aqiColor.withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('US EPA Air Quality Index (AQI)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: AnimatedBuilder(
                          animation: _aqiAnimation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: (_aqiAnimation.value / 300).clamp(0.0, 1.0), // Max AQI for progress visualization
                                  strokeWidth: 10,
                                  backgroundColor: aqiColor.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(aqiColor),
                                ),
                                Text(
                                  _aqiAnimation.value.round().toString(),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: aqiColor),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _getAqiSubtitle(widget.airQuality?.usEpaIndex),
                        style: TextStyle(fontSize: 24, color: aqiColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      _getAqiAdvice(widget.airQuality?.usEpaIndex),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    if (widget.airQuality != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Pollutant Levels', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _buildPollutantRow(context, 'Carbon Monoxide (CO)', widget.airQuality!.carbonMonoxide),
                      _buildPollutantRow(context, 'Ozone (O3)', widget.airQuality!.ozone),
                      _buildPollutantRow(context, 'Nitrogen Dioxide (NO2)', widget.airQuality!.nitrogenDioxide),
                      _buildPollutantRow(context, 'Sulphur Dioxide (SO2)', widget.airQuality!.sulphurDioxide),
                      _buildPollutantRow(context, 'PM2.5', widget.airQuality!.pm2_5),
                      _buildPollutantRow(context, 'PM10', widget.airQuality!.pm10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantRow(BuildContext context, String label, num? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value != null ? value.toStringAsFixed(2) : 'N/A', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getAqiSubtitle(num? aqi) {
    if (aqi == null) return 'N/A';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(BuildContext context, num? aqi) {
    if (aqi == null) return Colors.grey; // Changed from Theme.of(context).colorScheme.onSurface for better animation
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700; // Darker yellow for better contrast
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAqiAdvice(num? aqi) {
    if (aqi == null) return 'No data available.';
    if (aqi <= 50) return 'Air quality is excellent. It\'s a great day for outdoor activities.';
    if (aqi <= 100) return 'Air quality is acceptable. Unusually sensitive people should consider reducing prolonged or heavy exertion.';
    if (aqi <= 150) return 'People with respiratory or heart disease, the elderly, and children should limit prolonged exertion.';
    if (aqi <= 200) return 'Everyone may begin to experience health effects. People with respiratory or heart disease, the elderly, and children should avoid prolonged exertion.';
    if (aqi <= 300) return 'Health alert: everyone may experience more serious health effects. Avoid all outdoor exertion.';
    return 'Health warning of emergency conditions. The entire population is more likely to be affected.';
  }
}