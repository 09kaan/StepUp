import 'package:health/health.dart';

/// Apple Sağlık / Health Connect'ten okuma yapar.
class HealthService {
  final Health _health = Health();

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.FLIGHTS_CLIMBED,
  ];

  /// İzin ister (gerekirse Health Connect'i de yapılandırır).
  Future<bool> requestPermission() async {
    await _health.configure();
    final permissions = _types.map((_) => HealthDataAccess.READ).toList();
    return _health.requestAuthorization(_types, permissions: permissions);
  }

  /// Bugünün (00:00 -> şimdi) özeti.
  Future<HealthSummary> getTodaySummary() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;

    final data = await _health.getHealthDataFromTypes(
      types: const [
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.FLIGHTS_CLIMBED,
      ],
      startTime: midnight,
      endTime: now,
    );

    double distance = 0;
    double calories = 0;
    int flights = 0;

    for (final point in data) {
      final value =
          (point.value as NumericHealthValue).numericValue.toDouble();

      switch (point.type) {
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          distance += value;
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          calories += value;
          break;
        case HealthDataType.FLIGHTS_CLIMBED:
          flights += value.round();
          break;
        default:
          break;
      }
    }

    return HealthSummary(
      steps: steps,
      distanceMeters: distance,
      activeCalories: calories,
      flightsClimbed: flights,
    );
  }
}

/// Basit veri taşıyıcı.
class HealthSummary {
  final int steps;
  final double distanceMeters;
  final double activeCalories;
  final int flightsClimbed;

  const HealthSummary({
    required this.steps,
    required this.distanceMeters,
    required this.activeCalories,
    this.flightsClimbed = 0,
  });
}
