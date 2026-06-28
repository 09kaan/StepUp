import 'package:isar/isar.dart';

import '../models/challenge.dart';
import '../models/challenge_template.dart';

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

    final templates = await isar.challengeTemplates
        .filter()
        .enabledEqualTo(true)
        .findAll();

    final toCreate = templates
        .map((t) => Challenge.create(
              title: t.title,
              type: ChallengeType.daily,
              unit: t.unit,
              goalValue: t.goalValue,
              startDate: today,
              verification: t.verification,
            ))
        .toList();

    if (toCreate.isEmpty) return;

    await isar.writeTxn(() async {
      await isar.challenges.putAll(toCreate);
    });
  }

  /// Bugünkü günlük görevleri silip şablonlardan yeniden üretir.
  Future<void> regenerateToday() async {
    final today = _dayKey(DateTime.now());

    final existing = await isar.challenges
        .filter()
        .typeEqualTo(ChallengeType.daily)
        .startDateEqualTo(today)
        .findAll();

    await isar.writeTxn(() async {
      await isar.challenges.deleteAll(existing.map((c) => c.id).toList());
    });

    await ensureTodayChallenges();
  }

  /// Son [days] günde verilen başlıklı görevin kaç gün tamamlandığını sayar.
  Future<int> completedCountLastDays(String title, int days) async {
    final from = _dayKey(DateTime.now()).subtract(Duration(days: days - 1));

    final list = await isar.challenges
        .filter()
        .typeEqualTo(ChallengeType.daily)
        .titleEqualTo(title)
        .isCompletedEqualTo(true)
        .startDateGreaterThan(from, include: true)
        .findAll();

    return list.length;
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
