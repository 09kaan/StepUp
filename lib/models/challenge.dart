import 'package:isar/isar.dart';

part 'challenge.g.dart';

enum ChallengeType { daily, solo, duel, league }
enum ChallengeUnit { reps, steps, km, minutes }
enum VerificationKind { auto, manual }

@collection
class Challenge {
  Id id = Isar.autoIncrement;

  late String title;

  @enumerated
  late ChallengeType type;

  @enumerated
  late ChallengeUnit unit;

  late double goalValue;
  double progress = 0;

  late DateTime startDate;
  DateTime? endDate;

  bool isCompleted = false;

  @enumerated
  late VerificationKind verification;

  Challenge();

  Challenge.create({
    required this.title,
    required this.type,
    required this.unit,
    required this.goalValue,
    this.progress = 0,
    DateTime? startDate,
    this.endDate,
    this.isCompleted = false,
    this.verification = VerificationKind.manual,
  }) : startDate = startDate ?? DateTime.now();

  /// 0.0 - 1.0 arası ilerleme oranı (UI halkası/çubuğu için)
  @ignore
  double get progressFraction =>
      goalValue > 0 ? (progress / goalValue).clamp(0.0, 1.0) : 0.0;
}
