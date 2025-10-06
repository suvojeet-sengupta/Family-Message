import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  double _dragOffset = 0.0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isRefreshing) return;
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_dragOffset > 100) {
      setState(() {
        _isRefreshing = true;
        _animationController.repeat();
      });
      await widget.onRefresh();
      setState(() {
        _isRefreshing = false;
        _dragOffset = 0;
        _animationController.stop();
      });
    }
    setState(() {
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: _dragOffset - 30,
              left: 0,
              right: 0,
              child: Center(
                child: RotationTransition(
                  turns: _animationController,
                  child: const Icon(Icons.wb_sunny, color: Colors.amber, size: 30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
