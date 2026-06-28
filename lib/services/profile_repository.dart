import 'package:isar/isar.dart';

import '../models/challenge.dart';
import '../models/walk_session.dart';

class ProfileStats {
  final double totalWalkKm;
  final int walkCount;
  final double totalElevationMeters;
  final int completedChallenges;

  const ProfileStats({
    required this.totalWalkKm,
    required this.walkCount,
    required this.totalElevationMeters,
    required this.completedChallenges,
  });
}

class ProfileRepository {
  final Isar isar;

  ProfileRepository(this.isar);

  Future<ProfileStats> compute() async {
    final walks = await isar.walkSessions.where().findAll();
    double km = 0;
    double elev = 0;

    for (final w in walks) {
      km += w.distanceMeters / 1000;
      // elev += w.elevationGainMeters; // WalkSession'da bu alan tanımlanmamış
    }

    final completed =
        await isar.challenges.filter().isCompletedEqualTo(true).count();

    return ProfileStats(
      totalWalkKm: km,
      walkCount: walks.length,
      totalElevationMeters: elev,
      completedChallenges: completed,
    );
  }
}
