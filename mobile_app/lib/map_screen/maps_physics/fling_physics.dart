import 'dart:math';
import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class FlingPhysicsController {
  AnimatedMapController controller;

  FlingPhysicsController({required this.controller}) {
    controller.mapController.mapEventStream.listen((event) {
      handleEvent(event);
    });
  }

  Future<void> handleEvent(MapEvent event) async {
    // if (event.source == MapEventSource.dragStart) {
    //   print("Drag started");
    //   prevDragCoords = event.camera.center;
    //   dragStopWatch.reset();
    //   dragStopWatch.start();
    // }
    //
    // if (event.source == MapEventSource.dragEnd) {
    //   dragStopWatch.stop();
    //   final dragEndCoords = event.camera.center;
    //
    //   // Вычисляем разницу между координатами
    //   final Offset startPixel = latLngToPixel(prevDragCoords, _currZoom);
    //   final Offset endPixel = latLngToPixel(dragEndCoords, _currZoom);
    //   final double deltaLat = dragEndCoords.latitude - prevDragCoords.latitude;
    //   final double deltaLng = dragEndCoords.longitude - prevDragCoords.longitude;
    //
    //   final Offset vector = endPixel - startPixel;
    //   final double distance = vector.distance;
    //
    //   print("Drag ended, duration: ${dragStopWatch.elapsedMilliseconds}ms, pixel distance: $distance");
    //
    //   // Рассчитываем скорость в пикселях в секунду
    //   final double durationSec = dragStopWatch.elapsedMilliseconds / 1000;
    //   final double velocity = distance / (durationSec > 0 ? durationSec : 1);
    //   // Вычисляем скорость (изменение координат за секунду)
    //
    //   // Пороговое значение, подберите экспериментально
    //   print(velocity);
    //   const double minVelocityThreshold = 500.0;
    //   if (velocity < minVelocityThreshold) {
    //     print("Drag too slow, no animation triggered.");
    //   } else {
    //     // Вычисляем смещение для анимации пропорционально вектору перетаскивания.
    //     // Множитель также подбирается экспериментально.
    //     const double flingMultiplier = 2;
    //     final LatLng targetCoords = LatLng(
    //       dragEndCoords.latitude + (deltaLat * flingMultiplier),
    //       dragEndCoords.longitude + (deltaLng * flingMultiplier),
    //     );
    //
    //     _animatedMapController.animateTo(
    //       dest: targetCoords,
    //     );
    //   }
    // }
  }

  Offset latLngToPixel(LatLng latLng, double zoom) {
    // Стандартный размер тайла – 256 пикселей.
    final num scale = 256 * pow(2, zoom);
    final double x = (latLng.longitude + 180) / 360 * scale;

    // Преобразование широты в Y-пиксель по проекции Меркатора.
    double siny = sin(latLng.latitude * pi / 180);
    // Ограничиваем значение, чтобы избежать бесконечностей.
    siny = siny.clamp(-0.9999, 0.9999);
    final double y = (0.5 - log((1 + siny) / (1 - siny)) / (4 * pi)) * scale;

    return Offset(x, y);
  }

}
