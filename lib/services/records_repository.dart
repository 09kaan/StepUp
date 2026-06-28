import 'package:isar/isar.dart';

import '../models/daily_activity.dart';
import '../models/walk_session.dart';

class PersonalRecords {
  final int bestDaySteps;
  final DateTime? bestDayDate;
  final double longestWalkKm;
  final DateTime? longestWalkDate;
  final int longestWalkSeconds;
  final double highestElevation;
  final DateTime? highestElevationDate;
  final int longestStreak;
  final int totalSteps;
  final double totalKm;
  const PersonalRecords({
    required this.bestDaySteps,
    required this.bestDayDate,
    required this.longestWalkKm,
    required this.longestWalkDate,
    required this.longestWalkSeconds,
    required this.highestElevation,
    required this.highestElevationDate,
    required this.longestStreak,
    required this.totalSteps,
    required this.totalKm,
  });
}

class RecordsRepository {
  final Isar isar;
  RecordsRepository(this.isar);

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<PersonalRecords> compute() async {
    final days = await isar.dailyActivitys.where().findAll();
    final sessions = await isar.walkSessions.where().findAll();

    DailyActivity? bestDay;
    int totalSteps = 0;
    for (final d in days) {
      totalSteps += d.steps;
      if (bestDay == null || d.steps > bestDay.steps) bestDay = d;
    }

    WalkSession? longestWalk;
    double totalKm = 0;
    for (final s in sessions) {
      totalKm += s.distanceMeters / 1000;
      if (longestWalk == null ||
          s.distanceMeters > longestWalk.distanceMeters) {
        longestWalk = s;
      }
    }

    return PersonalRecords(
      bestDaySteps: bestDay?.steps ?? 0,
      bestDayDate: bestDay?.date,
      longestWalkKm: (longestWalk?.distanceMeters ?? 0) / 1000,
      longestWalkDate: longestWalk?.startTime,
      longestWalkSeconds: longestWalk?.durationSeconds ?? 0,
      highestElevation: 0,
      highestElevationDate: null,
      longestStreak: _longestStreak(days),
      totalSteps: totalSteps,
      totalKm: totalKm,
    );
  }

  int _longestStreak(List<DailyActivity> days) {
    final counted = <String>{};
    for (final a in days) {
      if (a.goalReached || a.streakProtected) {
        counted.add(_key(DateTime(a.date.year, a.date.month, a.date.day)));
      }
    }
    if (counted.isEmpty) return 0;
    int best = 0;
    for (final a in days) {
      if (!(a.goalReached || a.streakProtected)) continue;
      final d = DateTime(a.date.year, a.date.month, a.date.day);
      final prevKey = _key(DateTime(d.year, d.month, d.day - 1));
      if (counted.contains(prevKey)) continue; // serinin basi degil
      int len = 1;
      var cur = d;
      while (counted.contains(_key(DateTime(cur.year, cur.month, cur.day + 1)))) {
        len++;
        cur = DateTime(cur.year, cur.month, cur.day + 1);
      }
      if (len > best) best = len;
    }
    return best;
  }
}
