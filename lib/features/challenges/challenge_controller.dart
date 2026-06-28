import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../models/challenge.dart';
import '../../services/challenge_repository.dart';
import '../dashboard/dashboard_controller.dart'; // todayActivityProvider

final challengeRepoProvider = Provider<ChallengeRepository>(
  (ref) => ChallengeRepository(ref.watch(isarProvider)),
);

final todayChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repo = ref.watch(challengeRepoProvider);
  await repo.ensureTodayChallenges();

  // Otomatik km görevini bugünkü mesafeyle güncelle (varsa).
  try {
    final today = await ref.watch(todayActivityProvider.future);
    await repo.updateAutoProgress(today.distanceMeters / 1000);
  } catch (_) {
    // Sağlık izni yoksa otomatik görev 0 kalır; sorun değil.
  }

  return repo.todayChallenges();
});
