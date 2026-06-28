import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart'; // isarProvider
import '../../services/stats_repository.dart';

final statsRepoProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(isarProvider)),
);

final weeklyStatsProvider = FutureProvider<StatsSummary>(
  (ref) => ref.watch(statsRepoProvider).summary(7),
);

final monthlyStatsProvider = FutureProvider<StatsSummary>(
  (ref) => ref.watch(statsRepoProvider).summary(30),
);
