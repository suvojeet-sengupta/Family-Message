import 'package:flutter/material.dart';

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

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  _RefreshState _state = _RefreshState.idle;
  double _dragOffset = 0.0;

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.metrics.extentBefore == 0) {
      setState(() {
        _state = _RefreshState.dragging;
      });
    }
    if (_state == _RefreshState.dragging && notification is ScrollUpdateNotification) {
      setState(() {
        _dragOffset = (notification.metrics.pixels * -1) / 2.0;
      });
    }
    if (_state == _RefreshState.dragging && notification is ScrollEndNotification) {
      if (_dragOffset > 60) {
        setState(() {
          _state = _RefreshState.refreshing;
          _dragOffset = 0;
        });
        widget.onRefresh().whenComplete(() {
          if (mounted) {
            setState(() {
              _state = _RefreshState.idle;
            });
          }
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
    double indicatorHeight = 0;
    double indicatorOpacity = 0;

    if (_state == _RefreshState.dragging) {
      indicatorHeight = _dragOffset;
      indicatorOpacity = (_dragOffset / 100).clamp(0.0, 1.0);
    } else if (_state == _RefreshState.refreshing) {
      indicatorHeight = 60;
      indicatorOpacity = 1.0;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: Stack(
        children: [
          widget.child,
          if (_state != _RefreshState.idle)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: indicatorOpacity,
                  child: SizedBox(
                    height: indicatorHeight,
                    width: 30,
                    child: _state == _RefreshState.refreshing
                        ? const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          )
                        : Transform.rotate(
                            angle: -_dragOffset * 0.1,
                            child: const Icon(Icons.arrow_downward, color: Colors.white, size: 30),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
