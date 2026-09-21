import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum GpsPowerMode {
  active,
  autoPaused,
}

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

  Stream<Position> positionStream({
    GpsPowerMode mode = GpsPowerMode.active,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: _settings(mode),
    );
  }

  double distanceBetween(
          double lat1, double lng1, double lat2, double lng2) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

  LocationSettings _settings(GpsPowerMode mode) {
    final isAutoPaused = mode == GpsPowerMode.autoPaused;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: isAutoPaused ? 8 : 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: isAutoPaused
            ? LocationAccuracy.medium
            : LocationAccuracy.high,
        distanceFilter: isAutoPaused ? 20 : 10,
        intervalDuration: Duration(
          seconds: isAutoPaused ? 10 : 5,
        ),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: isAutoPaused
              ? 'FitWalk yürüyüşü duraklatıldı'
              : 'FitWalk yürüyüşü kaydediyor',
          notificationText: isAutoPaused
              ? 'Hareket ettiğinde takip devam edecek'
              : 'Rota takibi aktif',
          enableWakeLock: !isAutoPaused,
        ),
      );
    }

    return LocationSettings(
      accuracy: isAutoPaused
          ? LocationAccuracy.medium
          : LocationAccuracy.high,
      distanceFilter: isAutoPaused ? 20 : 10,
    );
  }
}
