import '../models/daily_activity.dart';

class GoalSuggestion {
  final int currentGoal;
  final int suggestedGoal;

  const GoalSuggestion({
    required this.currentGoal,
    required this.suggestedGoal,
  });
}

class SuggestionService {
  const SuggestionService();

  /// Son 7 günün hepsinde hedef tutturulduysa ve adımlar hedefi rahatça
  /// aşıyorsa, ~%10 (en yakın 500'e yuvarlanmış) yeni adım hedefi önerir.
  GoalSuggestion? suggestStepGoal(
      List<DailyActivity> recent, int currentGoal) {
    if (recent.length < 7 || currentGoal <= 0) return null;

    final last7 =
        recent.length <= 7 ? recent : recent.sublist(recent.length - 7);

    final allReached = last7.every((d) => d.steps >= currentGoal);

    if (!allReached) return null;

    final total = last7.fold<int>(0, (sum, d) => sum + d.steps);
    final avg = total / last7.length;

    if (avg < currentGoal + 250) return null; // sadece rahat aşıyorsa

    final raw = (currentGoal * 1.1).round();
    final suggested = ((raw + 250) ~/ 500) * 500;

    if (suggested <= currentGoal) return null;

    return GoalSuggestion(
        currentGoal: currentGoal, suggestedGoal: suggested);
  }

  /// Bir görevi son [window] günün hepsinde tamamladıysan daha yüksek hedef
  /// önerir. Küçük değerlerde 0.5'e, büyük değerlerde tam sayıya yuvarlar.
  double? suggestChallengeGoal(double currentGoal, int completedDays,
      {int window = 7}) {
    if (completedDays < window || currentGoal <= 0) return null;

    final raw = currentGoal * 1.1;
    final next =
        raw < 20 ? (raw * 2).round() / 2 : raw.roundToDouble();

    return next > currentGoal ? next : null;
  }
}
