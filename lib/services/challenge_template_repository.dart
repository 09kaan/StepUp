import 'package:isar/isar.dart';

import '../models/challenge.dart';
import '../models/challenge_template.dart';

class ChallengeTemplateRepository {
  final Isar isar;

  ChallengeTemplateRepository(this.isar);

  /// İlk açılışta varsayılan görev şablonlarını oluşturur.
  Future<void> ensureDefaults() async {
    final count = await isar.challengeTemplates.count();
    if (count > 0) return;

    await isar.writeTxn(() async {
      await isar.challengeTemplates.putAll([
        ChallengeTemplate()
          ..title = 'Şınav'
          ..unit = ChallengeUnit.reps
          ..goalValue = 10
          ..verification = VerificationKind.manual
          ..sortOrder = 0,
        ChallengeTemplate()
          ..title = 'Mekik'
          ..unit = ChallengeUnit.reps
          ..goalValue = 10
          ..verification = VerificationKind.manual
          ..sortOrder = 1,
        ChallengeTemplate()
          ..title = 'Yürüyüş'
          ..unit = ChallengeUnit.km
          ..goalValue = 3
          ..verification = VerificationKind.auto
          ..sortOrder = 2,
      ]);
    });
  }

  /// Şablonları canlı dinler (sortOrder'a göre sıralı).
  Stream<List<ChallengeTemplate>> watch() {
    return isar.challengeTemplates
        .where()
        .watch(fireImmediately: true)
        .map((list) =>
            list..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
  }

  Future<List<ChallengeTemplate>> enabledTemplates() async {
    final all = await isar.challengeTemplates
        .filter()
        .enabledEqualTo(true)
        .findAll();
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  Future<void> save(ChallengeTemplate t) async {
    await isar.writeTxn(() async {
      await isar.challengeTemplates.put(t);
    });
  }

  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.challengeTemplates.delete(id);
    });
  }

  Future<void> setEnabled(int id, bool enabled) async {
    await isar.writeTxn(() async {
      final t = await isar.challengeTemplates.get(id);
      if (t == null) return;
      t.enabled = enabled;
      await isar.challengeTemplates.put(t);
    });
  }
}
