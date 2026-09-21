import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';
import 'package:pedometer/pedometer.dart';

import '../../main.dart'; // isarProvider
import '../../models/walk_session.dart';
import '../../services/location_tracking_service.dart';
import '../../services/step_service.dart';

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
  final bool hasRecentGrade;
  final bool hasGpsSignal;
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
    this.hasRecentGrade = false,
    this.hasGpsSignal = true,
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
    bool? hasRecentGrade,
    bool? hasGpsSignal,
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
      hasRecentGrade: hasRecentGrade ?? this.hasRecentGrade,
      hasGpsSignal: hasGpsSignal ?? this.hasGpsSignal,
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
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _pedestrianSub;
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
  static const Duration noLocationAutoPauseDelay = Duration(seconds: 30);

  // Güncel eğim eşikleri (son ~20m yuvarlanan mesafe)
  static const double gradeMinDistance = 15.0;
  static const double gradeTargetDistance = 20.0;
  static const double gradeMaxDistance = 30.0;
  static const Duration gradeStaleAfter = Duration(seconds: 20);

  DateTime? _lowSpeedStartTime;
  DateTime? _lastAccuratePositionAt;
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
  final List<_AltitudeSample> _altitudeSamples = [];
  DateTime? _lastGradeAt;
  final List<RoutePoint> _recorded = [];

  // Pedometre ve GPS kesintisi mesafe tahmini değişkenleri
  int _latestStepCount = 0;
  DateTime? _lastStepAt;
  int? _autoPauseStepBaseline;
  DateTime? _autoPauseStepStartedAt;
  GpsGap? _gpsGap;
  double _estimatedStrideMeters = 0.72;

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
    _lastAccuratePositionAt = DateTime.now();
    _gpsGap = null;
    _autoPauseStepBaseline = null;
    _autoPauseStepStartedAt = null;
    _lastStepAt = null;

    state = const WalkTrackingState(isTracking: true);

    _subscribePedometer();
    _startCheckpointTimer();
    _startElapsedTimer();
    await _setGpsPowerMode(GpsPowerMode.active);
  }

  void _subscribePedometer() {
    _stepSub?.cancel();
    _pedestrianSub?.cancel();

    try {
      final stepService = _ref.read(stepServiceProvider);
      _stepSub = stepService.stepCountStream.listen(
        _handleStepCount,
        onError: (_) {},
        cancelOnError: false,
      );

      _pedestrianSub = stepService.pedestrianStatusStream.listen(
        (status) {
          if (status.status == 'walking') {
            _lastStepAt = DateTime.now();
          }
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}
  }

  Future<void> _handleStepCount(StepCount event) async {
    final currentSteps = event.steps;
    _lastStepAt = DateTime.now();
    _latestStepCount = currentSteps;

    if (!state.isAutoPaused) return;
    if (_autoPauseStepBaseline == null || _autoPauseStepStartedAt == null) return;

    final stepsSincePause = currentSteps - _autoPauseStepBaseline!;
    final elapsed = DateTime.now().difference(_autoPauseStepStartedAt!);

    // 10 saniye içinde en az 6 adım: kullanıcının tekrar yürüdüğüne dair güçlü kanıt.
    if (stepsSincePause >= 6 && elapsed <= const Duration(seconds: 10)) {
      await _resumeFromAutoPause();
    }
  }

  Future<void> _resumeFromAutoPause() async {
    if (!state.isAutoPaused || _activeSession == null) {
      return;
    }

    _last = null;
    _lowSpeedStartTime = null;
    _autoPauseStepBaseline = null;
    _autoPauseStepStartedAt = null;
    _lastAccuratePositionAt = DateTime.now();
    _lastResumeAt = DateTime.now();

    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      isAutoPaused: false,
      isManuallyPaused: false,
      hasRecentGrade: false,
      hasGpsSignal: true,
      error: null,
    );

    await _setGpsPowerMode(GpsPowerMode.active);
    await checkpoint();
  }

  void _startElapsedTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isTracking) return;

      if (!state.isPaused) {
        final now = DateTime.now();
        final isGradeStale = _lastGradeAt == null ||
            now.difference(_lastGradeAt!) >= gradeStaleAfter;

        final hasGps = _lastAccuratePositionAt != null &&
            now.difference(_lastAccuratePositionAt!) < noLocationAutoPauseDelay;

        // GPS kesintisi başladığında boşluk (gap) kaydını başlat
        if (!hasGps && _gpsGap == null && _last != null) {
          _gpsGap = GpsGap(
            lastGoodPosition: _last!,
            startedAt: _lastAccuratePositionAt ?? now,
            stepCountAtStart: _latestStepCount,
          );
        }

        state = state.copyWith(
          elapsed: Duration(seconds: _currentMovingSeconds),
          hasRecentGrade: isGradeStale ? false : state.hasRecentGrade,
          hasGpsSignal: hasGps,
        );

        _checkAutoPauseTimeout();
      }
    });
  }

  void _checkAutoPauseTimeout() {
    if (!state.isTracking ||
        state.isPaused ||
        state.isManuallyPaused) {
      return;
    }

    final now = DateTime.now();

    // Pedometre güvenliği: Son 20 saniyede adım atıldıysa kullanıcı hareket halindedir.
    final hasRecentSteps = _lastStepAt != null &&
        now.difference(_lastStepAt!) < const Duration(seconds: 20);

    if (hasRecentSteps) {
      _lowSpeedStartTime = null;
      return;
    }

    final lowSpeedExpired = _lowSpeedStartTime != null &&
        now.difference(_lowSpeedStartTime!) >= autoPauseDelay;

    // GPS yoksa / eskiyse duraklatma kararı vermiyoruz!
    final hasRecentAccurateLocation = _lastAccuratePositionAt != null &&
        now.difference(_lastAccuratePositionAt!) < noLocationAutoPauseDelay;

    if (hasRecentAccurateLocation && lowSpeedExpired) {
      unawaited(_triggerAutoPause());
    }
  }

  Future<void> _triggerAutoPause() async {
    if (!state.isTracking ||
        state.isPaused ||
        state.isManuallyPaused) {
      return;
    }

    if (_lastResumeAt != null) {
      final activeSeconds =
          DateTime.now().difference(_lastResumeAt!).inSeconds;

      _accumulatedMovingSeconds += activeSeconds;
    }

    _lastResumeAt = null;
    _lastAltitudePos = null;
    _lastValidAltitude = null;
    _altitudeBuffer.clear();
    _altitudeSamples.clear();
    _lastGradeAt = null;

    _lowSpeedStartTime = null;
    _lastAccuratePositionAt = null;
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();
    _gpsGap = null;

    // Adım sayacıyla otomatik devam başlangıç referansları
    _autoPauseStepBaseline = _latestStepCount;
    _autoPauseStepStartedAt = DateTime.now();

    state = state.copyWith(
      isPaused: true,
      isAutoPaused: true,
      isManuallyPaused: false,
      currentGradePercent: 0,
      hasRecentGrade: false,
      elapsed: Duration(
        seconds: _accumulatedMovingSeconds,
      ),
      elevationGainMeters: _totalElevationGain,
    );

    await checkpoint();
    await _setGpsPowerMode(GpsPowerMode.autoPaused);
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
    _altitudeSamples.clear();
    _lastGradeAt = null;
    _lowSpeedStartTime = null;
    _lastAccuratePositionAt = null;
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
      hasRecentGrade: false,
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
    _altitudeSamples.clear();
    _lastGradeAt = null;
    _lowSpeedStartTime = null;
    _lastAccuratePositionAt = DateTime.now();
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();
    _gpsGap = null;
    _autoPauseStepBaseline = null;
    _autoPauseStepStartedAt = null;

    _lastResumeAt = DateTime.now();

    state = state.copyWith(
      isTracking: true,
      isPaused: false,
      isManuallyPaused: false,
      isAutoPaused: false,
      hasRecentGrade: false,
      hasGpsSignal: true,
      hasRecoveredSession: false,
      error: null,
    );

    _subscribePedometer();

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
    if (isAccurate) {
      _lastAccuratePositionAt = DateTime.now();
    }

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
          _lastAccuratePositionAt = DateTime.now();
          _autoPauseStepBaseline = null;
          _autoPauseStepStartedAt = null;

          _lastAltitudePos = null;
          _lastValidAltitude = null;
          _altitudeBuffer.clear();
          _altitudeSamples.clear();
          _lastGradeAt = null;

          _recorded.addAll(_pendingResumePoints);

          state = state.copyWith(
            isPaused: false,
            isAutoPaused: false,
            isManuallyPaused: false,
            hasRecentGrade: false,
            hasGpsSignal: true,
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
    // GPS kesintisinden sonraki ilk doğru nokta:
    // GPS boşluğundaki mesafeyi adım + doğrudan mesafe + süre kontrolüyle tahmin et
    if (isAccurate && _gpsGap != null) {
      final gap = _gpsGap!;
      _gpsGap = null;

      final gapSteps = (_latestStepCount > gap.stepCountAtStart)
          ? (_latestStepCount - gap.stepCountAtStart)
          : 0;
      final gapSeconds =
          pos.timestamp.difference(gap.startedAt).inMilliseconds / 1000.0;

      final directDistance = service.distanceBetween(
        gap.lastGoodPosition.latitude,
        gap.lastGoodPosition.longitude,
        pos.latitude,
        pos.longitude,
      );

      final stepDistance = gapSteps * _estimatedStrideMeters;
      final timeLimit = (gapSeconds > 0 ? gapSeconds : 1.0) * 2.5;

      final gpsLowerBound = (directDistance -
              gap.lastGoodPosition.accuracy -
              pos.accuracy)
          .clamp(0.0, double.infinity);

      double estimatedGapDistance;
      if (gapSteps > 0) {
        estimatedGapDistance = stepDistance.clamp(gpsLowerBound, timeLimit);
      } else {
        estimatedGapDistance = gpsLowerBound.clamp(0.0, timeLimit);
      }

      // Yeni GPS sabitlemesi (anchor): Bu noktayı yeni başlangıç noktası yap
      _last = pos;
      _lowSpeedStartTime = null;

      state = state.copyWith(
        distanceMeters: state.distanceMeters + estimatedGapDistance,
        hasGpsSignal: true,
      );
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

    _checkAutoPauseTimeout();
    if (state.isPaused) return;

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
    bool newHasRecentGrade = state.hasRecentGrade;
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
          _lastAltitudePos = pos;
          _lastValidAltitude = smoothedAlt;
        } else if (altDiff <= -1.5 && hDist >= 5.0) {
          _lastAltitudePos = pos;
          _lastValidAltitude = smoothedAlt;
        } else if (hDist >= 25.0) {
          _lastAltitudePos = pos;
          _lastValidAltitude = smoothedAlt;
        }
      }

      // Son ~20 metreye dayalı güncel eğim (rolling distance grade) hesabı:
      final currentDistance = state.distanceMeters + added;
      _altitudeSamples.add(_AltitudeSample(
        altitude: smoothedAlt,
        distanceMeters: currentDistance,
        timestamp: pos.timestamp,
      ));

      _altitudeSamples.removeWhere(
        (s) => (currentDistance - s.distanceMeters) > (gradeMaxDistance + 15.0),
      );

      _AltitudeSample? bestSample;
      double bestDelta = double.infinity;

      for (final s in _altitudeSamples) {
        final dist = currentDistance - s.distanceMeters;
        if (dist >= gradeMinDistance && dist <= gradeMaxDistance) {
          final delta = (dist - gradeTargetDistance).abs();
          if (delta < bestDelta) {
            bestDelta = delta;
            bestSample = s;
          }
        }
      }

      if (bestSample != null) {
        final dist = currentDistance - bestSample.distanceMeters;
        final altDiff = smoothedAlt - bestSample.altitude;
        newGrade = ((altDiff / dist) * 100).clamp(-30.0, 30.0);
        newHasRecentGrade = true;
        _lastGradeAt = DateTime.now();
      }
    }

    if (_lastGradeAt == null ||
        DateTime.now().difference(_lastGradeAt!) >= gradeStaleAfter) {
      newHasRecentGrade = false;
    }

    state = state.copyWith(
      points: acceptPoint
          ? [...state.points, LatLng(pos.latitude, pos.longitude)]
          : state.points,
      distanceMeters: state.distanceMeters + added,
      elevationGainMeters: _totalElevationGain,
      currentGradePercent: newGrade,
      hasRecentGrade: newHasRecentGrade,
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
    _stepSub?.cancel();
    _pedestrianSub?.cancel();

    _checkpointTimer = null;
    _timer = null;
    _sub = null;
    _stepSub = null;
    _pedestrianSub = null;
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
    _lastAccuratePositionAt = null;
    _consecutiveResumePoints = 0;
    _pendingResumeDistance = 0;
    _pendingResumePoints.clear();
    _gpsGap = null;
    _autoPauseStepBaseline = null;
    _autoPauseStepStartedAt = null;
    _lastStepAt = null;
    _gpsPowerMode = GpsPowerMode.active;
    _isSwitchingGpsMode = false;

    _altitudeBuffer.clear();
    _altitudeSamples.clear();
    _lastGradeAt = null;
    _recorded.clear();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _pedestrianSub?.cancel();
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

class _AltitudeSample {
  final double altitude;
  final double distanceMeters;
  final DateTime timestamp;

  const _AltitudeSample({
    required this.altitude,
    required this.distanceMeters,
    required this.timestamp,
  });
}

class GpsGap {
  final Position lastGoodPosition;
  final DateTime startedAt;
  final int stepCountAtStart;

  const GpsGap({
    required this.lastGoodPosition,
    required this.startedAt,
    required this.stepCountAtStart,
  });
}
