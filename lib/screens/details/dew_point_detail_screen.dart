import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_service.dart'; // Import SettingsService for TemperatureUnit

class DewPointDetailScreen extends StatefulWidget {
  final double dewPoint;
  final TemperatureUnit temperatureUnit;

  const DewPointDetailScreen({super.key, required this.dewPoint, required this.temperatureUnit});

  @override
  State<DewPointDetailScreen> createState() => _DewPointDetailScreenState();
}

class _DewPointDetailScreenState extends State<DewPointDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dewPointAnimation;
  double _currentDewPoint = 0;

  @override
  void initState() {
    super.initState();
    _currentDewPoint = widget.dewPoint;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _dewPointAnimation = Tween<double>(begin: 0, end: _currentDewPoint).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DewPointDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dewPoint != widget.dewPoint) {
      _currentDewPoint = widget.dewPoint;
      _dewPointAnimation = Tween<double>(begin: oldWidget.dewPoint, end: _currentDewPoint).animate(
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

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  List<Color> _getDewPointColors(double tempC) {
    if (tempC >= 24) {
      return [Colors.red.shade700, Colors.red.shade900]; // Extremely uncomfortable
    } else if (tempC >= 21) {
      return [Colors.orange.shade700, Colors.orange.shade900]; // Very humid
    } else if (tempC >= 18) {
      return [Colors.deepOrange.shade400, Colors.deepOrange.shade700]; // Somewhat uncomfortable
    } else if (tempC >= 16) {
      return [Colors.yellow.shade700, Colors.yellow.shade900]; // A bit humid
    } else if (tempC >= 10) {
      return [Colors.green.shade400, Colors.green.shade700]; // Comfortable
    } else {
      return [Colors.blue.shade400, Colors.blue.shade700]; // Dry
    }
  }

  String _getDewPointAdvice(double temp) {
    // Convert to Celsius for advice logic, as the advice thresholds are likely based on Celsius.
    final tempC = widget.temperatureUnit == TemperatureUnit.fahrenheit ? _fahrenheitToCelsius(temp) : temp;
    if (tempC >= 24) {
      return 'Extremely uncomfortable and oppressive. It will feel very muggy.';
    } else if (tempC >= 21) {
      return 'Very humid and uncomfortable.';
    } else if (tempC >= 18) {
      return 'Somewhat uncomfortable for most people.';
    } else if (tempC >= 16) {
      return 'Okay for most, but feels a bit humid.';
    } else if (tempC >= 10) {
      return 'Comfortable.';
    } else {
      return 'A bit dry for some.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDewPoint = widget.temperatureUnit == TemperatureUnit.fahrenheit
        ? _celsiusToFahrenheit(widget.dewPoint) // Assuming dewPoint is always passed in Celsius
        : widget.dewPoint;
    final tempUnitSymbol = widget.temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dew Point'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentDewPoint(context, displayDewPoint, tempUnitSymbol),
            const SizedBox(height: 24),
            _buildDewPointInfo(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentDewPoint(BuildContext context, double displayDewPoint, String tempUnitSymbol) {
    return AnimatedBuilder(
      animation: _dewPointAnimation,
      builder: (context, child) {
        final currentDewPoint = widget.temperatureUnit == TemperatureUnit.fahrenheit
            ? _celsiusToFahrenheit(_dewPointAnimation.value)
            : _dewPointAnimation.value;
        final tempCForColor = _fahrenheitToCelsius(currentDewPoint); // Always use Celsius for color logic
        final gradientColors = _getDewPointColors(tempCForColor);
        final textColor = (tempCForColor >= 18 || tempCForColor < 10) ? Colors.white : Colors.black; // Adjust text color based on background

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Current Dew Point',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                '${currentDewPoint.round()}$tempUnitSymbol',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w200, color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                _getDewPointAdvice(currentDewPoint),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8), height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDewPointInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Dew Point?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The dew point is the temperature to which air must be cooled to become saturated with water vapor. When cooled further, the airborne water vapor will condense to form liquid water (dew). A higher dew point indicates more moisture in the air and can make the temperature feel more humid.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
