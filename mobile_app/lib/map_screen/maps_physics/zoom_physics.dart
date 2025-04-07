import 'dart:developer';

import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class ZoomPhysicsController {
  late double _minZoom;
  late double _maxZoom;
  late double _zoomLevel;
  final Duration deltaTimeThreshold = Duration(milliseconds: 800);
  late double _prevZoomLevel = _zoomLevel;
  final Stopwatch _zoomStopWatch = Stopwatch();
  AnimatedMapController controller;

  ZoomPhysicsController({required this.controller, zoomLevel = 11.0, minZoom = 2.0, maxZoom = 18.0}) {
    _zoomLevel = zoomLevel;
    _maxZoom = maxZoom;
    _minZoom = minZoom;
    controller.mapController.mapEventStream.listen((event) {
      handleEvent(event);
    });
  }

  Future<void> handleEvent(MapEvent event) async {
    if (event is MapEventMove) {
      _zoomLevel = event.camera.zoom;
    }

    if (event.source == MapEventSource.multiFingerGestureStart) {
      _prevZoomLevel = event.camera.zoom;
      _zoomStopWatch.reset();
      _zoomStopWatch.start();
      return;
    }

    if (event.source == MapEventSource.multiFingerEnd) {
      _zoomStopWatch.stop();

      if (deltaTimeThreshold.inMilliseconds < _zoomStopWatch.elapsedMilliseconds) {
        return;
      }

      final acceleration = _calculateAcceleration();
      final targetZoom = (_zoomLevel + acceleration).clamp(_minZoom, _maxZoom);
      if (targetZoom == _zoomLevel) {
        return;
      }

      controller
          .animateTo(curve: Curves.decelerate, zoom: targetZoom, cancelPreviousAnimations: false)
          .then((v) => _prevZoomLevel = targetZoom);
      return;
    }

  }

  double _calculateAcceleration({double scale = 0.2, double threshold = 0.8}) {
    final deltaZoom = (_zoomLevel - _prevZoomLevel);
    final deltaTime = _zoomStopWatch.elapsedMilliseconds;
    double acceleration = deltaZoom / deltaTime * 1000 * scale;

    if (acceleration.isNaN || acceleration.isInfinite || acceleration.abs() < threshold) {
      return 0;
    }
    return acceleration;
  }

  double get zoom => _zoomLevel;

  double get minZoom => _minZoom;

  double get maxZoom => _maxZoom;
}
