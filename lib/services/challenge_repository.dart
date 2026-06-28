import 'package:isar/isar.dart';
import '../models/challenge.dart';

class ChallengeRepository {
  final Isar isar;

  ChallengeRepository(this.isar);

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Bugünün günlük görevleri yoksa varsayılanları oluşturur.
  Future<void> ensureTodayChallenges() async {
    final today = _dayKey(DateTime.now());
    final existing = await isar.challenges
        .filter()
        .typeEqualTo(ChallengeType.daily)
        .startDateEqualTo(today)
        .findAll();

    if (existing.isNotEmpty) return;

    final defaults = [
      Challenge.create(
        title: '10 Şınav',
        type: ChallengeType.daily,
        unit: ChallengeUnit.reps,
        goalValue: 10,
        startDate: today,
        verification: VerificationKind.manual,
      ),
      Challenge.create(
        title: '10 Mekik',
        type: ChallengeType.daily,
        unit: ChallengeUnit.reps,
        goalValue: 10,
        startDate: today,
        verification: VerificationKind.manual,
      ),
      Challenge.create(
        title: '3 km Yürüyüş',
        type: ChallengeType.daily,
        unit: ChallengeUnit.km,
        goalValue: 3,
        startDate: today,
        verification: VerificationKind.auto,
      ),
    ];

    await isar.writeTxn(() async {
      await isar.challenges.putAll(defaults);
    });
  }

  Future<List<Challenge>> todayChallenges() {
    final today = _dayKey(DateTime.now());
    return isar.challenges
        .filter()
        .typeEqualTo(ChallengeType.daily)
        .startDateEqualTo(today)
        .findAll();
  }

  /// Manuel görevi tamamla / geri al.
  Future<void> setManualComplete(int id, bool done) async {
    await isar.writeTxn(() async {
      final c = await isar.challenges.get(id);
      if (c == null) return;
      c.isCompleted = done;
      c.progress = done ? c.goalValue : 0;
      await isar.challenges.put(c);
    });
  }

  /// Otomatik (km) görevleri bugünkü mesafeye göre günceller.
  Future<void> updateAutoProgress(double todayKm) async {
    final today = _dayKey(DateTime.now());
    final autos = await isar.challenges
        .filter()
        .typeEqualTo(ChallengeType.daily)
        .startDateEqualTo(today)
        .verificationEqualTo(VerificationKind.auto)
        .findAll();

    await isar.writeTxn(() async {
      for (final c in autos) {
        if (c.unit == ChallengeUnit.km) {
          c.progress = todayKm;
          c.isCompleted = todayKm >= c.goalValue;
          await isar.challenges.put(c);
        }
      }
    });
  }
}
