import 'package:isar/isar.dart';
import '../models/daily_activity.dart';
import 'health_service.dart';

class DailyActivityRepository {
  final Isar isar;

  DailyActivityRepository(this.isar);

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Bugünün kaydını oluşturur/günceller (gün başına tek kayıt).
  Future<DailyActivity> upsertToday(
    HealthSummary summary, {
    int goalSteps = 6000,
  }) async {
    final today = _dayKey(DateTime.now());
    late DailyActivity record;

    await isar.writeTxn(() async {
      record = await isar.dailyActivitys
          .filter()
          .dateEqualTo(today)
          .findFirst() ??
          DailyActivity.create(date: today, goalSteps: goalSteps);

      record.steps = summary.steps;
      record.distanceMeters = summary.distanceMeters;
      record.activeCalories = summary.activeCalories;
      record.goalSteps = goalSteps;
      record.goalReached = summary.steps >= goalSteps;

      await isar.dailyActivitys.put(record);
    });

    return record;
  }

  /// Son [days] günün kayıtları (streak hesabı için, Adım 4).
  Future<List<DailyActivity>> recentDays(int days) {
    final from =
        _dayKey(DateTime.now()).subtract(Duration(days: days - 1));

    return isar.dailyActivitys
        .filter()
        .dateGreaterThan(from.subtract(const Duration(milliseconds: 1)))
        .sortByDate()
        .findAll();
  }
}
