import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../logger/logger.dart';

/// Сначала проверяем сервис и разрешения
Future<void> _checkPermissions() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw 'Location services are disabled.';
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
  }
}

/// Получение самой точной позиции с таймаутом
Future<Position> _getCurrentPositionWithTimeout({
  LocationAccuracy accuracy = LocationAccuracy.high,
  Duration timeout = const Duration(seconds: 5),
}) =>
    Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
    ).timeout(timeout);

/// Последняя известная позиция
Future<LatLng?> getLastKnownPosition() async {
  final pos = await Geolocator.getLastKnownPosition();
  if (pos == null) return null;
  return LatLng(pos.latitude, pos.longitude);
}

/// Основная функция: пытаемся получить текущую позицию, иначе — последнюю известную
Future<LatLng?> getPosition() async {
  try {
    await _checkPermissions();
  } catch (e, stack) {
    return null;
  }
  final last = await getLastKnownPosition();

  try {
    final pos = await _getCurrentPositionWithTimeout(
      accuracy: LocationAccuracy.high,
      timeout: const Duration(milliseconds: 300),
    );
    return LatLng(pos.latitude, pos.longitude);
  } on TimeoutException catch (e) {
    Logger().error('getCurrentPosition timed out: $e');
  } catch (e) {
    Logger().error('Error getting current position: $e');
  }

  if (last != null) {
    return last;
  }

  throw 'Unable to determine position.';
}

/// Пример подписки на поток обновлений позиций
// Stream<LatLng> positionStream({
//   LocationAccuracy accuracy = LocationAccuracy.high,
//   int distanceFilter = 10, // в метрах
// }) {
//   final settings = LocationSettings(
//     accuracy: accuracy,
//     distanceFilter: distanceFilter,
//   );
//   return Geolocator.getPositionStream(locationSettings: settings).map(
//         (pos) => LatLng(pos.latitude, pos.longitude),
//   );
// }
