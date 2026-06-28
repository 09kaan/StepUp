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

  const WalkTrackingState({
    this.isTracking = false,
    this.points = const [],
    this.distanceMeters = 0,
    this.elapsed = Duration.zero,
    this.error,
  });

  WalkTrackingState copyWith({
    bool? isTracking,
    List<LatLng>? points,
    double? distanceMeters,
    Duration? elapsed,
    String? error,
  }) {
    return WalkTrackingState(
      isTracking: isTracking ?? this.isTracking,
      points: points ?? this.points,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      error: error,
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
    _recorded.clear();
    state = const WalkTrackingState(isTracking: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        state = state.copyWith(
            elapsed: DateTime.now().difference(_startTime!));
      }
    });

    _sub = service.positionStream().listen((pos) {
      double added = 0;
      if (_last != null) {
        added = service.distanceBetween(
            _last!.latitude, _last!.longitude, pos.latitude, pos.longitude);
      }
      _last = pos;
      _recorded.add(RoutePoint.of(pos.latitude, pos.longitude, DateTime.now()));

      state = state.copyWith(
        points: [...state.points, LatLng(pos.latitude, pos.longitude)],
        distanceMeters: state.distanceMeters + added,
      );
    });
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

    final session = WalkSession()
      ..startTime = _startTime!
      ..endTime = DateTime.now()
      ..distanceMeters = state.distanceMeters
      ..points = List.of(_recorded);

    final isar = _ref.read(isarProvider); // user note applied

    await isar.writeTxn(() async {
      await isar.walkSessions.put(session);
    });

    _startTime = null;
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
