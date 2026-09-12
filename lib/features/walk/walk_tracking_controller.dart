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
  final bool isPaused;
  final bool isRestoring;
  final bool hasRecoveredSession;
  final List<LatLng> points;
  final double distanceMeters;
  final Duration elapsed;
  final String? error;
  final double elevationGainMeters;
  final double currentGradePercent;
  final double currentAltitude;

  const WalkTrackingState({
    this.isTracking = false,
    this.isPaused = false,
    this.isRestoring = false,
    this.hasRecoveredSession = false,
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
    bool? isPaused,
    bool? isRestoring,
    bool? hasRecoveredSession,
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
      isPaused: isPaused ?? this.isPaused,
      isRestoring: isRestoring ?? this.isRestoring,
      hasRecoveredSession:
          hasRecoveredSession ?? this.hasRecoveredSession,
      points: points ?? this.points,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      error: error,
      elevationGainMeters:
          elevationGainMeters ?? this.elevationGainMeters,
      currentGradePercent:
          currentGradePercent ?? this.currentGradePercent,
      currentAltitude: currentAltitude ?? this.currentAltitude,
    );
  }
}

class WalkTrackingController extends StateNotifier<WalkTrackingState> {
  WalkTrackingController(this._ref) : super(const WalkTrackingState()) {
    _findRecoverableWalk();
  }

  final Ref _ref;
  StreamSubscription<Position>? _sub;
  Timer? _timer;
  Timer? _checkpointTimer;

  WalkSession? _activeSession;
  DateTime? _lastResumeAt;
  int _accumulatedMovingSeconds = 0;

  Position? _last;
  Position? _lastAltitudePos;
  double? _lastValidAltitude;
  double _totalElevationGain = 0;
  double _climbingDistanceMeters = 0;
  double? _maxAltitude;
  final List<double> _altitudeBuffer = [];
  final List<RoutePoint> _recorded = [];

  int get _currentMovingSeconds {
    if (_lastResumeAt == null) {
      return _accumulatedMovingSeconds;
    }
    return _accumulatedMovingSeconds +
        DateTime.now().difference(_lastResumeAt!).inSeconds;
  }

  Future<void> _findRecoverableWalk() async {
    state = state.copyWith(isRestoring: true);

    try {
      final isar = _ref.read(isarProvider);

      final session = await isar.walkSessions
          .filter()
          .isActiveEqualTo(true)
          .findFirst();

      if (session == null) {
        state = state.copyWith(
          isRestoring: false,
          hasRecoveredSession: false,
        );
        return;
      }

      _activeSession = session;
      _recorded
        ..clear()
        ..addAll(session.points);

      _totalElevationGain = session.elevationGainMeters;
      _maxAltitude =
          session.maxAltitude == 0 ? null : session.maxAltitude;

      _accumulatedMovingSeconds = session.movingDurationSeconds;
      _lastResumeAt = null;

      final mapPoints = session.points
          .map((p) => LatLng(p.lat, p.lng))
          .toList();

      state = WalkTrackingState(
        isTracking: false,
        isPaused: true,
        isRestoring: false,
        hasRecoveredSession: true,
        points: mapPoints,
        distanceMeters: session.distanceMeters,
        elapsed: Duration(
          seconds: session.movingDurationSeconds,
        ),
        elevationGainMeters: session.elevationGainMeters,
        currentAltitude:
            session.points.isNotEmpty ? session.points.last.altitude : 0,
      );
    } catch (error) {
      state = state.copyWith(
        isRestoring: false,
        error: 'Yarım kalan yürüyüş kontrol edilemedi.',
      );
    }
  }

  Future<void> start() async {
    final service = _ref.read(locationServiceProvider);
    final ok = await service.ensurePermission();
    if (!ok) {
      state = state.copyWith(error: 'Konum izni gerekli. Ayarlardan izin ver.');
      return;
    }

    _resetController();

    final session = WalkSession()
      ..startTime = DateTime.now()
      ..isActive = true
      ..isPaused = false
      ..movingDurationSeconds = 0
      ..distanceMeters = 0
      ..elevationGainMeters = 0
      ..avgGradePercent = 0
      ..maxAltitude = 0
      ..points = [];

    final isar = _ref.read(isarProvider);

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });

    _activeSession = session;
    _accumulatedMovingSeconds = 0;
    _lastResumeAt = DateTime.now();

    state = const WalkTrackingState(isTracking: true);

    _startCheckpointTimer();
    _startElapsedTimer();
    _startLocationStream();
  }

  void _startElapsedTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isTracking || state.isPaused) return;
      state = state.copyWith(
        elapsed: Duration(seconds: _currentMovingSeconds),
      );
    });
  }

  void _startCheckpointTimer() {
    _checkpointTimer?.cancel();
    _checkpointTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => checkpoint(),
    );
  }

  Future<void> checkpoint() async {
    final session = _activeSession;
    if (session == null) return;

    final isar = _ref.read(isarProvider);

    session
      ..isActive = true
      ..isPaused = state.isPaused
      ..distanceMeters = state.distanceMeters
      ..elevationGainMeters = _totalElevationGain
      ..maxAltitude = _maxAltitude ?? 0
      ..movingDurationSeconds = _currentMovingSeconds
      ..lastCheckpointAt = DateTime.now()
      ..points = List<RoutePoint>.of(_recorded);

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });
  }

  Future<void> pause() async {
    if (!state.isTracking || state.isPaused) return;

    if (_lastResumeAt != null) {
      _accumulatedMovingSeconds +=
          DateTime.now().difference(_lastResumeAt!).inSeconds;
    }

    _lastResumeAt = null;
    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _altitudeBuffer.clear();

    await _sub?.cancel();
    _sub = null;

    state = state.copyWith(
      isPaused: true,
      currentGradePercent: 0,
      elapsed: Duration(seconds: _accumulatedMovingSeconds),
    );

    await checkpoint();
  }

  Future<void> resume() async {
    if (!state.isPaused || _activeSession == null) return;

    final service = _ref.read(locationServiceProvider);
    final allowed = await service.ensurePermission();

    if (!allowed) {
      state = state.copyWith(
        error: 'Devam etmek için konum izni gerekli.',
      );
      return;
    }

    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _altitudeBuffer.clear();

    _lastResumeAt = DateTime.now();

    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      hasRecoveredSession: false,
      error: null,
    );

    _startLocationStream();
    _startElapsedTimer();
    _startCheckpointTimer();

    await checkpoint();
  }

  Future<void> _startLocationStream() async {
    await _sub?.cancel();

    final service = _ref.read(locationServiceProvider);

    _sub = service.positionStream().listen(
      _handlePosition,
      onError: _handleLocationError,
    );
  }

  void _handleLocationError(dynamic error) {
    state = state.copyWith(
      error: 'Konum alınamadı. GPS ayarlarını kontrol et.',
    );
  }

  void _handlePosition(Position pos) {
    if (!state.isTracking || state.isPaused) return;

    final service = _ref.read(locationServiceProvider);

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

      // Hız kontrolü: Maksimum 7.0 m/s (~25.2 km/s - yürüyüş/koşu için üst sınır)
      final isReasonableSpeed = speed <= 7.0;
      final isReasonableSegment = dist >= 2.0 && isReasonableSpeed;

      if (isAccurate) {
        if (isReasonableSegment) {
          added = dist;
          _last = pos;
          acceptPoint = true;
        } else if (!isReasonableSpeed) {
          // İmkânsız hız / sıçrama tespit edildi (araç veya teleport);
          // Mesafeye eklemeden referans noktasını güncelle ki kilitlenme olmasın
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
  }

  Future<WalkSession?> stop() async {
    if (_lastResumeAt != null) {
      _accumulatedMovingSeconds +=
          DateTime.now().difference(_lastResumeAt!).inSeconds;
    }
    _lastResumeAt = null;

    _checkpointTimer?.cancel();
    _timer?.cancel();
    await _sub?.cancel();

    _checkpointTimer = null;
    _timer = null;
    _sub = null;

    final session = _activeSession;
    if (session == null) {
      _resetController();
      state = const WalkTrackingState();
      return null;
    }

    // Gerçek ortalama tırmanış eğimi: Yalnızca yokuş yukarı tırmanılan segmentlerin mesafesi baz alınır
    final avgClimbingGrade =
        (_climbingDistanceMeters > 0 && _totalElevationGain > 0)
            ? ((_totalElevationGain / _climbingDistanceMeters) * 100).clamp(0.0, 35.0)
            : 0.0;

    session
      ..endTime = DateTime.now()
      ..isActive = false
      ..isPaused = false
      ..distanceMeters = state.distanceMeters
      ..elevationGainMeters = _totalElevationGain
      ..avgGradePercent = avgClimbingGrade
      ..maxAltitude = _maxAltitude ?? 0
      ..movingDurationSeconds = _accumulatedMovingSeconds
      ..lastCheckpointAt = DateTime.now()
      ..points = List<RoutePoint>.of(_recorded);

    final isar = _ref.read(isarProvider);

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });

    _resetController();
    state = const WalkTrackingState();
    return session;
  }

  Future<void> discardRecoveredWalk() async {
    final session = _activeSession;
    if (session == null) return;

    final isar = _ref.read(isarProvider);

    await isar.writeTxn(() async {
      await isar.walkSessions.delete(session.id);
    });

    _resetController();
    state = const WalkTrackingState();
  }

  void _resetController() {
    _checkpointTimer?.cancel();
    _timer?.cancel();
    _sub?.cancel();

    _checkpointTimer = null;
    _timer = null;
    _sub = null;
    _activeSession = null;
    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _lastResumeAt = null;
    _accumulatedMovingSeconds = 0;
    _totalElevationGain = 0;
    _climbingDistanceMeters = 0;
    _maxAltitude = null;

    _altitudeBuffer.clear();
    _recorded.clear();
  }

  @override
  void dispose() {
    _checkpointTimer?.cancel();
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}

final walkTrackingControllerProvider =
    StateNotifierProvider<WalkTrackingController, WalkTrackingState>(
        (ref) => WalkTrackingController(ref));

final walkHistoryProvider = StreamProvider<List<WalkSession>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.walkSessions
      .filter()
      .isActiveEqualTo(false)
      .watch(fireImmediately: true)
      .map(
        (list) => list
          ..sort(
            (a, b) => b.startTime.compareTo(a.startTime),
          ),
      );
});
