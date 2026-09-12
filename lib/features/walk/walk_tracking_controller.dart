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
  final bool isManuallyPaused;
  final bool isAutoPaused;
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
    this.isManuallyPaused = false,
    this.isAutoPaused = false,
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
    bool? isManuallyPaused,
    bool? isAutoPaused,
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
    final manualPaused = isManuallyPaused ?? this.isManuallyPaused;
    final autoPaused = isAutoPaused ?? this.isAutoPaused;
    final paused = isPaused ?? (manualPaused || autoPaused);

    return WalkTrackingState(
      isTracking: isTracking ?? this.isTracking,
      isPaused: paused,
      isManuallyPaused: manualPaused,
      isAutoPaused: autoPaused,
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

  GpsPowerMode _gpsPowerMode = GpsPowerMode.active;
  bool _isSwitchingGpsMode = false;

  // Otomatik duraklatma ve devam etme eşikleri
  static const double autoPauseSpeed = 0.4; // m/s (~1.44 km/h)
  static const double autoResumeSpeed = 0.8; // m/s (~2.88 km/h)
  static const Duration autoPauseDelay = Duration(seconds: 20);

  DateTime? _lowSpeedStartTime;
  int _consecutiveResumePoints = 0;
  double _pendingResumeDistance = 0;
  final List<RoutePoint> _pendingResumePoints = [];

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
      _climbingDistanceMeters = session.climbingDistanceMeters;
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
        isManuallyPaused: true,
        isAutoPaused: false,
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
    await _setGpsPowerMode(GpsPowerMode.active);
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
      ..climbingDistanceMeters = _climbingDistanceMeters
      ..maxAltitude = _maxAltitude ?? 0
      ..movingDurationSeconds = _currentMovingSeconds
      ..lastCheckpointAt = DateTime.now()
      ..points = List<RoutePoint>.of(_recorded);

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });
  }

  Future<void> pause() async {
    if (!state.isTracking || state.isManuallyPaused) return;

    if (_lastResumeAt != null) {
      _accumulatedMovingSeconds +=
          DateTime.now().difference(_lastResumeAt!).inSeconds;
    }

    _lastResumeAt = null;
    _last = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _altitudeBuffer.clear();
    _lowSpeedStartTime = null;
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();

    await _sub?.cancel();
    _sub = null;

    state = state.copyWith(
      isPaused: true,
      isManuallyPaused: true,
      isAutoPaused: false,
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
    _lowSpeedStartTime = null;
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();

    _lastResumeAt = DateTime.now();

    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      isManuallyPaused: false,
      isAutoPaused: false,
      hasRecoveredSession: false,
      error: null,
    );

    _startElapsedTimer();
    _startCheckpointTimer();
    await _setGpsPowerMode(GpsPowerMode.active);

    await checkpoint();
  }

  Future<void> _setGpsPowerMode(GpsPowerMode mode) async {
    if (_gpsPowerMode == mode && _sub != null) return;
    if (_isSwitchingGpsMode) return;

    _isSwitchingGpsMode = true;

    try {
      await _sub?.cancel();
      _sub = null;

      _gpsPowerMode = mode;

      final locationService = _ref.read(locationServiceProvider);

      _sub = locationService
          .positionStream(mode: mode)
          .listen(
            _handlePosition,
            onError: (Object error, StackTrace stackTrace) {
              _handleLocationError(error);
            },
          );
    } finally {
      _isSwitchingGpsMode = false;
    }
  }

  void _handleLocationError(dynamic error) {
    state = state.copyWith(
      error: 'Konum alınamadı. GPS ayarlarını kontrol et.',
    );
  }

  void _handlePosition(Position pos) {
    if (!state.isTracking || state.isManuallyPaused) return;

    final service = _ref.read(locationServiceProvider);
    final isAccurate = pos.accuracy > 0 && pos.accuracy <= 20.0;

    // --- DURUM 1: OTOMATİK DURAKLATILMIŞ DURUMDA DEVAM ETME (AUTO-RESUME) KONTROLÜ ---
    if (state.isAutoPaused) {
      if (!isAccurate) return;

      if (_last == null) {
        _last = pos;
        return;
      }

      final dist = service.distanceBetween(
        _last!.latitude,
        _last!.longitude,
        pos.latitude,
        pos.longitude,
      );
      final timeDelta =
          pos.timestamp.difference(_last!.timestamp).inMilliseconds / 1000.0;
      final speed = timeDelta > 0 ? (dist / timeDelta) : double.infinity;

      // İki ardışık geçerli noktada hız 0.8 m/s üzerine çıkarsa devam et
      if (dist >= 2.0 && speed >= autoResumeSpeed && speed <= 7.0) {
        _consecutiveResumePoints++;
        _pendingResumeDistance += dist;

        _pendingResumePoints.add(
          RoutePoint.of(
            pos.latitude,
            pos.longitude,
            pos.timestamp,
            pos.altitude,
            pos.altitudeAccuracy,
            _accumulatedMovingSeconds,
          ),
        );

        _last = pos;

        if (_consecutiveResumePoints >= 2) {
          _lowSpeedStartTime = null;
          _lastResumeAt = DateTime.now();

          _lastAltitudePos = null;
          _lastValidAltitude = null;
          _altitudeBuffer.clear();

          _recorded.addAll(_pendingResumePoints);

          state = state.copyWith(
            isPaused: false,
            isAutoPaused: false,
            isManuallyPaused: false,
            points: [
              ...state.points,
              ..._pendingResumePoints.map(
                (p) => LatLng(p.lat, p.lng),
              ),
            ],
            distanceMeters:
                state.distanceMeters + _pendingResumeDistance,
          );

          _pendingResumeDistance = 0;
          _pendingResumePoints.clear();
          _consecutiveResumePoints = 0;

          unawaited(
            _setGpsPowerMode(GpsPowerMode.active),
          );

          checkpoint();
        }
      } else {
        _consecutiveResumePoints = 0;
        _pendingResumeDistance = 0;
        _pendingResumePoints.clear();
        if (dist >= 2.0 && speed <= 7.0) {
          _last = pos;
        }
      }
      return;
    }

    // --- DURUM 2: NORMAL TAKİP & OTOMATİK DURAKLATMA (AUTO-PAUSE) KONTROLÜ ---
    double added = 0;
    bool acceptPoint = false;
    double currentSpeed = 0.0;

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
      currentSpeed = speed;

      final isReasonableSpeed = speed <= 7.0;
      final isReasonableSegment = dist >= 2.0 && isReasonableSpeed;

      if (isAccurate) {
        if (isReasonableSegment) {
          added = dist;
          _last = pos;
          acceptPoint = true;
        } else if (!isReasonableSpeed) {
          // İmkânsız hız / sıçrama (araç veya teleport); kilitlenmeyi önlemek için güncelle
          _last = pos;
        }
      }
    }

    // Hız 20 saniye boyunca 0.4 m/s altında kalırsa otomatik duraklat
    if (isAccurate) {
      if (acceptPoint) {
        if (currentSpeed < autoPauseSpeed) {
          _lowSpeedStartTime ??= DateTime.now();
        } else {
          _lowSpeedStartTime = null;
        }
      } else {
        // Nokta kabul edilmedi çünkü dist < 2.0m (kullanıcı hareketsiz / duruyor)
        _lowSpeedStartTime ??= DateTime.now();
      }
    }

    // 20 saniye doldu mu kontrolü
    if (_lowSpeedStartTime != null &&
        DateTime.now().difference(_lowSpeedStartTime!) >= autoPauseDelay) {
      if (_lastResumeAt != null) {
        final totalSeconds =
            DateTime.now().difference(_lastResumeAt!).inSeconds;
        final netMoving =
            (totalSeconds - autoPauseDelay.inSeconds).clamp(0, totalSeconds);
        _accumulatedMovingSeconds += netMoving;
      }

      _lastResumeAt = null;
      _last = pos;
      _lastAltitudePos = null;
      _lastValidAltitude = null;
      _altitudeBuffer.clear();
      _lowSpeedStartTime = null;
      _consecutiveResumePoints = 0;
      _pendingResumeDistance = 0;
      _pendingResumePoints.clear();

      state = state.copyWith(
        isPaused: true,
        isAutoPaused: true,
        isManuallyPaused: false,
        currentGradePercent: 0,
        elapsed: Duration(seconds: _accumulatedMovingSeconds),
        points: acceptPoint
            ? [...state.points, LatLng(pos.latitude, pos.longitude)]
            : state.points,
        distanceMeters: state.distanceMeters + added,
        elevationGainMeters: _totalElevationGain,
      );

      checkpoint();
      unawaited(
        _setGpsPowerMode(GpsPowerMode.autoPaused),
      );
      return;
    }

    if (acceptPoint) {
      _recorded.add(RoutePoint.of(
        pos.latitude,
        pos.longitude,
        pos.timestamp,
        pos.altitude,
        pos.altitudeAccuracy,
        _currentMovingSeconds,
      ));
    }

    // 2. Yükseklik Filtresi, Smoothing ve Tırmanış Eğimi:
    final hasAccurateAltitude =
        pos.altitudeAccuracy > 0 && pos.altitudeAccuracy <= 15.0;
    double newGrade = state.currentGradePercent;
    double currentDisplayAlt = state.currentAltitude;

    if (acceptPoint && hasAccurateAltitude) {
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
      ..climbingDistanceMeters = _climbingDistanceMeters
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
    _lowSpeedStartTime = null;
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();
    _gpsPowerMode = GpsPowerMode.active;
    _isSwitchingGpsMode = false;

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
