import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  /// Konum servisini ve iznini kontrol eder; gerekirse izin ister.
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(locationSettings: _settings());
  }

  double distanceBetween(
          double lat1, double lng1, double lat2, double lng2) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

  LocationSettings _settings() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'FitWalk yürüyüşü kaydediyor',
          notificationText: 'Rota takibi aktif',
          enableWakeLock: true,
        ),
      );
    }
    return const LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: 5);
  }
}
