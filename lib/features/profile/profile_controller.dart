import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../services/badge_service.dart';
import '../../services/profile_repository.dart';
import '../dashboard/dashboard_controller.dart'; // streakProvider

final profileRepoProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(isarProvider)),
);

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  return ref.watch(profileRepoProvider).compute();
});

final badgeServiceProvider = Provider((ref) => BadgeService());

final badgesProvider = FutureProvider<List<AppBadge>>((ref) async {
  final stats = await ref.watch(profileStatsProvider.future);
  final streak = await ref.watch(streakProvider.future);
  return ref.watch(badgeServiceProvider).evaluate(stats, streak);
});
