import 'package:flutter/material.dart';
import 'dart:math' as math;

enum _RefreshState {
  idle,
  dragging,
  refreshing,
}

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
  _RefreshState _state = _RefreshState.idle;
  double _dragOffset = 0.0;

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

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.metrics.extentBefore == 0) {
      setState(() {
        _state = _RefreshState.dragging;
      });
    }
    if (_state == _RefreshState.dragging && notification is ScrollUpdateNotification) {
      setState(() {
        _dragOffset = notification.metrics.pixels * -1;
      });
    }
    if (_state == _RefreshState.dragging && notification is ScrollEndNotification) {
      if (_dragOffset > 100) {
        setState(() {
          _state = _RefreshState.refreshing;
          _dragOffset = 0;
          _animationController.repeat();
        });
        widget.onRefresh().whenComplete(() {
          setState(() {
            _state = _RefreshState.idle;
            _animationController.stop();
          });
        });
      } else {
        setState(() {
          _state = _RefreshState.idle;
          _dragOffset = 0;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: Stack(
        children: [
          widget.child,
          if (_state != _RefreshState.idle)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: _dragOffset > 100 ? 100 : _dragOffset,
                  child: RotationTransition(
                    turns: _animationController,
                    child: const Icon(Icons.wb_sunny, color: Colors.amber, size: 30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
