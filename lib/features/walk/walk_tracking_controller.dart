import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';

import '../../main.dart'; // isarProvider
import '../../models/walk_session.dart';
import '../../services/location_tracking_service.dart';

final locationServiceProvider =
    Provider((ref) => LocationTrackingService());

class WalkTrackingState {
  final bool isTracking;
  final List<LatLng> points;
  final double distanceMeters;
  final Duration elapsed;
  final String? error;
  final double elevationGainMeters;
  final double currentGradePercent;
  final double currentAltitude;

  const WalkTrackingState({
    this.isTracking = false,
    this.points = const [],
    this.distanceMeters = 0,
    this.elapsed = Duration.zero,
    this.error,
    this.elevationGainMeters = 0,
    this.currentGradePercent = 0,
    this.currentAltitude = 0,
  });

  WalkTrackingState copyWith({
    bool? isTracking,
    List<LatLng>? points,
    double? distanceMeters,
    Duration? elapsed,
    String? error,
    double? elevationGainMeters,
    double? currentGradePercent,
    double? currentAltitude,
  }) {
    return WalkTrackingState(
      isTracking: isTracking ?? this.isTracking,
      points: points ?? this.points,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      error: error,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      currentGradePercent: currentGradePercent ?? this.currentGradePercent,
      currentAltitude: currentAltitude ?? this.currentAltitude,
    );
  }
}

class WalkTrackingController extends StateNotifier<WalkTrackingState> {
  WalkTrackingController(this._ref) : super(const WalkTrackingState());

  final Ref _ref;
  StreamSubscription<Position>? _sub;
  Timer? _timer;
  DateTime? _startTime;
  Position? _last;
  Position? _lastAltitudePos;
  double? _lastValidAltitude;
  double _totalElevationGain = 0;
  double _climbingDistanceMeters = 0;
  double? _maxAltitude;
  final List<double> _altitudeBuffer = [];
  final List<RoutePoint> _recorded = [];

  Future<void> start() async {
    final service = _ref.read(locationServiceProvider);
    final ok = await service.ensurePermission();
    if (!ok) {
      state = state.copyWith(error: 'Konum izni gerekli. Ayarlardan izin ver.');
      return;
    }

    _startTime = DateTime.now();
    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _totalElevationGain = 0;
    _climbingDistanceMeters = 0;
    _maxAltitude = null;
    _altitudeBuffer.clear();
    _recorded.clear();
    state = const WalkTrackingState(isTracking: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        state = state.copyWith(
            elapsed: DateTime.now().difference(_startTime!));
      }
    });

    _sub = service.positionStream().listen(
      (pos) {
        // 1. GPS Yatay Doğruluk & Mesafe Segment Filtresi:
        final isAccurate = pos.accuracy > 0 && pos.accuracy <= 20.0;
        double added = 0;
        bool acceptPoint = false;

        if (_last == null) {
          if (isAccurate) {
            _last = pos;
            acceptPoint = true;
          }
        } else {
          final dist = service.distanceBetween(
            _last!.latitude,
            _last!.longitude,
            pos.latitude,
            pos.longitude,
          );
          final timeDelta =
              pos.timestamp.difference(_last!.timestamp).inMilliseconds / 1000.0;
          final speed = timeDelta > 0 ? (dist / timeDelta) : double.infinity;

          // Hız kontrolü: Maksimum 7.0 m/s (~25.2 km/s - tempolu yürüyüş/koşu için güvenli üst sınır)
          // Sabit dist <= 100 sınırı kaldırıldı; böylece ekran kapalıyken 100m'den fazla
          // yüründüğünde rota kilitlenmez.
          final isReasonableSpeed = speed <= 7.0;
          final isReasonableSegment = dist >= 2.0 && isReasonableSpeed;

          if (isAccurate) {
            if (isReasonableSegment) {
              added = dist;
              _last = pos;
              acceptPoint = true;
            } else if (!isReasonableSpeed) {
              // İmkânsız hız / sıçrama tespit edildi (araç veya teleport);
              // Mesafeye eklemeden referans noktasını güncelle ki kilitlenme olmasın!
              _last = pos;
            }
          }
        }

        if (acceptPoint) {
          _recorded.add(RoutePoint.of(
            pos.latitude,
            pos.longitude,
            pos.timestamp,
            pos.altitude,
            pos.altitudeAccuracy,
          ));
        }

        // 2. Yükseklik Filtresi, Smoothing ve Tırmanış Eğimi:
        // SADECE kabul edilen geçerli rota noktaları yükseklik hesabına dahil edilir
        final hasAccurateAltitude =
            pos.altitudeAccuracy > 0 && pos.altitudeAccuracy <= 15.0;
        double newGrade = state.currentGradePercent;
        double currentDisplayAlt = state.currentAltitude;

        if (acceptPoint && hasAccurateAltitude) {
          // Son 4 noktanın hareketli ortalaması (smoothing)
          _altitudeBuffer.add(pos.altitude);
          if (_altitudeBuffer.length > 4) _altitudeBuffer.removeAt(0);
          final smoothedAlt =
              _altitudeBuffer.reduce((a, b) => a + b) / _altitudeBuffer.length;
          currentDisplayAlt = smoothedAlt;

          if (_maxAltitude == null || smoothedAlt > _maxAltitude!) {
            _maxAltitude = smoothedAlt;
          }

          if (_lastAltitudePos == null || _lastValidAltitude == null) {
            _lastAltitudePos = pos;
            _lastValidAltitude = smoothedAlt;
          } else {
            final hDist = service.distanceBetween(
              _lastAltitudePos!.latitude,
              _lastAltitudePos!.longitude,
              pos.latitude,
              pos.longitude,
            );
            final altDiff = smoothedAlt - _lastValidAltitude!;

            // 1.5m dikey ölü bölge + 5m yatay hareket şartı (dururken sahte tırmanışı önler)
            if (altDiff >= 1.5 && hDist >= 5.0) {
              _totalElevationGain += altDiff;
              _climbingDistanceMeters += hDist;
              newGrade = ((altDiff / hDist) * 100).clamp(-30.0, 30.0);
              _lastAltitudePos = pos;
              _lastValidAltitude = smoothedAlt;
            } else if (altDiff <= -1.5 && hDist >= 5.0) {
              newGrade = ((altDiff / hDist) * 100).clamp(-30.0, 30.0);
              _lastAltitudePos = pos;
              _lastValidAltitude = smoothedAlt;
            } else if (hDist >= 25.0) {
              newGrade = ((altDiff / hDist) * 100).clamp(-30.0, 30.0);
              _lastAltitudePos = pos;
              _lastValidAltitude = smoothedAlt;
            }
          }
        }

        state = state.copyWith(
          points: acceptPoint
              ? [...state.points, LatLng(pos.latitude, pos.longitude)]
              : state.points,
          distanceMeters: state.distanceMeters + added,
          elevationGainMeters: _totalElevationGain,
          currentGradePercent: newGrade,
          currentAltitude: currentDisplayAlt,
        );
      },
      onError: (error) {
        state = state.copyWith(
            error: 'Konum alınamadı. GPS ayarlarını kontrol et.');
      },
    );
  }

  Future<WalkSession?> stop() async {
    await _sub?.cancel();
    _timer?.cancel();
    _sub = null;
    _timer = null;

    if (_startTime == null) {
      state = const WalkTrackingState();
      return null;
    }

    // Gerçek ortalama tırmanış eğimi: Yalnızca yokuş yukarı tırmanılan segmentlerin mesafesi baz alınır
    final avgClimbingGrade =
        (_climbingDistanceMeters > 0 && _totalElevationGain > 0)
            ? ((_totalElevationGain / _climbingDistanceMeters) * 100).clamp(0.0, 35.0)
            : 0.0;

    final session = WalkSession()
      ..startTime = _startTime!
      ..endTime = DateTime.now()
      ..distanceMeters = state.distanceMeters
      ..elevationGainMeters = _totalElevationGain
      ..avgGradePercent = avgClimbingGrade
      ..maxAltitude = _maxAltitude ?? 0
      ..points = List.of(_recorded);

    final isar = _ref.read(isarProvider); // user note applied

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });

    _startTime = null;
    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _maxAltitude = null;
    _altitudeBuffer.clear();
    state = const WalkTrackingState();
    return session;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final walkTrackingControllerProvider =
    StateNotifierProvider<WalkTrackingController, WalkTrackingState>(
        (ref) => WalkTrackingController(ref));

final walkHistoryProvider = StreamProvider<List<WalkSession>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.walkSessions
      .where()
      .watch(fireImmediately: true)
      .map((list) => list..sort((a, b) => b.startTime.compareTo(a.startTime)));
});
