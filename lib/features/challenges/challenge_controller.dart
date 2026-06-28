import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../models/challenge.dart';
import '../../models/challenge_template.dart';
import '../../services/challenge_repository.dart';
import '../../services/challenge_template_repository.dart';
import '../../services/suggestion_service.dart';
import '../dashboard/dashboard_controller.dart'; // todayActivityProvider

final challengeRepoProvider = Provider<ChallengeRepository>(
  (ref) => ChallengeRepository(ref.watch(isarProvider)),
);

final challengeTemplateRepoProvider = Provider<ChallengeTemplateRepository>(
  (ref) => ChallengeTemplateRepository(ref.watch(isarProvider)),
);

/// Şablonları canlı dinler (düzenleme ekranı için).
final challengeTemplatesProvider = StreamProvider<List<ChallengeTemplate>>(
  (ref) => ref.watch(challengeTemplateRepoProvider).watch(),
);

final todayChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  await ref.watch(challengeTemplateRepoProvider).ensureDefaults();

  final repo = ref.watch(challengeRepoProvider);
  await repo.ensureTodayChallenges();

  try {
    final today = await ref.watch(todayActivityProvider.future);
    await repo.updateAutoProgress(today.distanceMeters / 1000);
  } catch (_) {
    // Sağlık izni yoksa otomatik görev 0 kalır; sorun değil.
  }

  return repo.todayChallenges();
});

/// Şablon id -> önerilen yeni hedef (son 7 gün hep tamamlanan görevler için).
final challengeSuggestionsProvider =
    FutureProvider<Map<int, double>>((ref) async {
  final repo = ref.watch(challengeRepoProvider);
  final templates =
      await ref.watch(challengeTemplateRepoProvider).enabledTemplates();

  final result = <int, double>{};
  for (final t in templates) {
    final done = await repo.completedCountLastDays(t.title, 7);
    final next =
        const SuggestionService().suggestChallengeGoal(t.goalValue, done);
    if (next != null) result[t.id] = next;
  }
  return result;
});
