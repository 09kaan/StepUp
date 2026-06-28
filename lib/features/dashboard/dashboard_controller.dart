import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../models/daily_activity.dart';
import '../../services/daily_activity_repository.dart';
import '../../services/health_service.dart';
import '../../services/settings_repository.dart';
import '../../services/streak_service.dart';
import '../../services/suggestion_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final dailyActivityRepoProvider = Provider<DailyActivityRepository>(
  (ref) => DailyActivityRepository(ref.watch(isarProvider)),
);

final streakServiceProvider = Provider<StreakService>(
  (ref) => StreakService(),
);

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(isarProvider));
});

final todayActivityProvider =
    FutureProvider<DailyActivity>((ref) async {
  final health = ref.watch(healthServiceProvider);
  final granted = await health.requestPermission();

  if (!granted) {
    throw Exception('Sağlık (Health) izni verilmedi.');
  }

  final summary = await health.getTodaySummary();
  final repo = ref.watch(dailyActivityRepoProvider);
  final goal = await ref.watch(settingsRepoProvider).stepGoal();

  return repo.upsertToday(summary, goalSteps: goal);
});

final goalSuggestionProvider =
    FutureProvider<GoalSuggestion?>((ref) async {
  final today = await ref.watch(todayActivityProvider.future);
  final repo = ref.watch(dailyActivityRepoProvider);
  final recent = await repo.recentDays(7);
  return const SuggestionService()
      .suggestStepGoal(recent, today.goalSteps);
});

final streakProvider = FutureProvider<StreakInfo>((ref) async {
  await ref.watch(todayActivityProvider.future);
  final repo = ref.watch(dailyActivityRepoProvider);
  final days = await repo.recentDays(365);
  return ref.watch(streakServiceProvider).compute(days);
});
