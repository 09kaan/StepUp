import 'package:isar/isar.dart';

part 'daily_activity.g.dart';

/// Günlük özet: streak ve geçmiş grafiği için her gün 1 kayıt.
@collection
class DailyActivity {
  Id id = Isar.autoIncrement;

  /// Günün başlangıcı (00:00). Gün başına tek kayıt için benzersiz.
  @Index(unique: true)
  late DateTime date;

  int steps = 0;
  double distanceMeters = 0;
  double activeCalories = 0;
  int goalSteps = 6000;
  bool goalReached = false;
  
  // YENİ: bu gün telafi (freeze) ile korundu mu?
  bool streakProtected = false;

  DailyActivity();

  DailyActivity.create({
    required this.date,
    this.steps = 0,
    this.distanceMeters = 0,
    this.activeCalories = 0,
    this.goalSteps = 6000,
    this.goalReached = false,
    this.streakProtected = false,
  });
}
