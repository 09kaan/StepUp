import 'package:isar/isar.dart';

import 'challenge.dart'; // ChallengeUnit, VerificationKind

part 'challenge_template.g.dart';

@collection
class ChallengeTemplate {
  Id id = Isar.autoIncrement;

  late String title;

  @enumerated
  ChallengeUnit unit = ChallengeUnit.reps;

  double goalValue = 10;

  @enumerated
  VerificationKind verification = VerificationKind.manual;

  bool enabled = true;

  int sortOrder = 0;

  ChallengeTemplate();
}
