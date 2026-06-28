import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSetting {
  Id id = 0; // tek satır ayar kaydı

  int dailyStepGoal = 6000;

  AppSetting();
}
