import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart'; // isarProvider
import '../../models/daily_activity.dart';
import '../../services/daily_activity_repository.dart';
import '../../services/health_service.dart';
import '../../services/step_service.dart';

// --- Adım 2: canlı sensör (yürüyor/duruyor rozeti) ---
final stepServiceProvider = Provider<StepService>((ref) => StepService());

final stepPermissionProvider = FutureProvider<bool>((ref) {
  return ref.read(stepServiceProvider).requestPermission();
});

final pedestrianStatusProvider = StreamProvider<String>((ref) async* {
  final granted = await ref.watch(stepPermissionProvider.future);
  if (!granted) return;

  final service = ref.watch(stepServiceProvider);
  yield* service.pedestrianStatusStream.map((e) => e.status);
});

// --- Adım 3: health + günlük kayıt ---
final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final dailyActivityRepoProvider = Provider<DailyActivityRepository>((ref) {
  return DailyActivityRepository(ref.watch(isarProvider));
});

/// Health'ten bugünkü özeti çeker, Isar'a yazar ve döndürür.
final todayActivityProvider = FutureProvider<DailyActivity>((ref) async {
  final health = ref.watch(healthServiceProvider);

  final granted = await health.requestPermission();
  if (!granted) {
    throw Exception('Sağlık (Health) izni verilmedi.');
  }

  final summary = await health.getTodaySummary();
  final repo = ref.watch(dailyActivityRepoProvider);
  return repo.upsertToday(summary);
});
