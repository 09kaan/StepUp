import 'package:isar/isar.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  final Isar isar;

  SettingsRepository(this.isar);

  Future<AppSetting> _load() async =>
      await isar.appSettings.get(0) ?? AppSetting();

  Future<int> stepGoal() async => (await _load()).dailyStepGoal;

  Future<void> setStepGoal(int goal) async {
    await isar.writeTxn(() async {
      final s = await isar.appSettings.get(0) ?? AppSetting();
      s.dailyStepGoal = goal;
      await isar.appSettings.put(s);
    });
  }
}
