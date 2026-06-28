import 'package:isar/isar.dart';

import '../models/daily_activity.dart';

class DayStat {
  final DateTime day;
  final int steps;
  final double km;
  final bool goalReached;
  const DayStat({
    required this.day,
    required this.steps,
    required this.km,
    required this.goalReached,
  });
}

class StatsSummary {
  final List<DayStat> days; // artan sirada, sabit uzunluk
  final int totalSteps;
  final double totalKm;
  final int avgSteps;
  final int goalDays;
  final int bestSteps;
  const StatsSummary({
    required this.days,
    required this.totalSteps,
    required this.totalKm,
    required this.avgSteps,
    required this.goalDays,
    required this.bestSteps,
  });
}

class StatsRepository {
  final Isar isar;
  StatsRepository(this.isar);

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<StatsSummary> summary(int days) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1));

    // Tum gunluk kayitlari al, gune gore esle (eksik gunler 0 olacak).
    final all = await isar.dailyActivitys.where().findAll();
    final byDay = <String, DailyActivity>{};
    for (final a in all) {
      final d = DateTime(a.date.year, a.date.month, a.date.day);
      byDay[_key(d)] = a;
    }

    final list = <DayStat>[];
    int totalSteps = 0;
    double totalKm = 0;
    int goalDays = 0;
    int bestSteps = 0;

    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i));
      final a = byDay[_key(d)];
      final steps = a?.steps ?? 0;
      final km = (a?.distanceMeters ?? 0) / 1000;
      final reached = a?.goalReached ?? false;
      list.add(DayStat(day: d, steps: steps, km: km, goalReached: reached));
      totalSteps += steps;
      totalKm += km;
      if (reached) goalDays++;
      if (steps > bestSteps) bestSteps = steps;
    }

    final avg = days > 0 ? (totalSteps / days).round() : 0;
    return StatsSummary(
      days: list,
      totalSteps: totalSteps,
      totalKm: totalKm,
      avgSteps: avg,
      goalDays: goalDays,
      bestSteps: bestSteps,
    );
  }
}
