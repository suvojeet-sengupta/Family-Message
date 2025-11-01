import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VisibilityDetailScreen extends StatefulWidget {
  final double visKm;
  final double visMiles;

  const VisibilityDetailScreen({super.key, required this.visKm, required this.visMiles});

  @override
  State<VisibilityDetailScreen> createState() => _VisibilityDetailScreenState();
}

class _VisibilityDetailScreenState extends State<VisibilityDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _visibilityAnimation;
  double _currentVisKm = 0;

  @override
  void initState() {
    super.initState();
    _currentVisKm = widget.visKm;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _visibilityAnimation = Tween<double>(begin: 0, end: _currentVisKm).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant VisibilityDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visKm != widget.visKm) {
      _currentVisKm = widget.visKm;
      _visibilityAnimation = Tween<double>(begin: oldWidget.visKm, end: _currentVisKm).animate(
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

  Color _getVisibilityColor(double km) {
    if (km > 10) {
      return Colors.blue.shade200; // Clear
    } else if (km > 5) {
      return Colors.lightBlue.shade200; // Good
    } else if (km > 2) {
      return Colors.grey.shade400; // Moderate
    } else if (km > 1) {
      return Colors.grey.shade600; // Poor
    } else {
      return Colors.grey.shade800; // Very Poor
    }
  }

  List<Color> _getGradientColors(double km) {
    if (km > 10) {
      return [Colors.blue.shade100, Colors.blue.shade400];
    } else if (km > 5) {
      return [Colors.lightBlue.shade100, Colors.lightBlue.shade400];
    } else if (km > 2) {
      return [Colors.grey.shade200, Colors.grey.shade500];
    } else if (km > 1) {
      return [Colors.grey.shade400, Colors.grey.shade700];
    } else {
      return [Colors.grey.shade600, Colors.grey.shade900];
    }
  }

  String _getVisibilityAdvice(double km) {
    if (km > 10) {
      return 'Excellent visibility. Great for outdoor activities and travel.';
    } else if (km > 5) {
      return 'Good visibility. Conditions are clear for most activities.';
    } else if (km > 2) {
      return 'Moderate visibility. Be cautious while driving, especially at high speeds.';
    } else if (km > 1) {
      return 'Poor visibility. Drive with extreme caution, use fog lights if necessary.';
    } else {
      return 'Very poor visibility (fog or heavy precipitation). Travel is not recommended if possible.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visibility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentVisibility(context),
            const SizedBox(height: 24),
            _buildVisibilityInfo(),
            const SizedBox(height: 24),
            _buildAdvice(),
          ],
        ).animate().fade(duration: 300.ms),
      ),
    );
  }

  Widget _buildCurrentVisibility(BuildContext context) {
    return AnimatedBuilder(
      animation: _visibilityAnimation,
      builder: (context, child) {
        final currentVis = _visibilityAnimation.value;
        final gradientColors = _getGradientColors(currentVis);
        final textColor = currentVis > 2 ? Colors.black : Colors.white; // Adjust text color based on background

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
                'Current Visibility',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                '${currentVis.toStringAsFixed(1)} km',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w200, color: textColor),
              ),
              Text(
                '(${widget.visMiles.toStringAsFixed(1)} miles)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                _getVisibilityAdvice(currentVis),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8), height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisibilityInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Visibility?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Visibility is a measure of the distance at which an object or light can be clearly discerned. In meteorology, it is an estimate of the distance at which a person can clearly see a large object.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvice() {
    // Advice is now integrated into _buildCurrentVisibility
    return const SizedBox.shrink();
  }
}
