import '../models/daily_activity.dart';

class StreakInfo {
  final int current; // güncel ardışık seri
  final int longest; // en uzun seri
  final int freezeAvailable; // kullanılabilir telafi hakkı

  const StreakInfo({
    required this.current,
    required this.longest,
    required this.freezeAvailable,
  });
}

class StreakService {
  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  StreakInfo compute(List<DailyActivity> days) {
    final goalDays = <DateTime>{};
    final protectedDays = <DateTime>{};

    for (final d in days) {
      final k = _key(d.date);
      if (d.goalReached) goalDays.add(k);
      if (d.streakProtected) protectedDays.add(k);
    }

    final kept = <DateTime>{...goalDays, ...protectedDays};
    if (kept.isEmpty) {
      return const StreakInfo(current: 0, longest: 0, freezeAvailable: 0);
    }

    // Güncel seri: bugünden (yoksa dünden) geriye doğru say
    final today = _key(DateTime.now());
    int current = 0;
    DateTime cursor =
        kept.contains(today) ? today : today.subtract(const Duration(days: 1));

    while (kept.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // En uzun seri
    final sorted = kept.toList()..sort();
    int longest = 0;
    int run = 0;
    DateTime? prev;

    for (final day in sorted) {
      run = (prev != null && day.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > longest) longest = run;
      prev = day;
    }

    // Telafi ekonomisi: her 7 hedef günü 1 hak; kullanılan = korunan gün sayısı
    final earned = goalDays.length ~/ 7;
    final used = protectedDays.length;
    final freezeAvailable = (earned - used) < 0 ? 0 : (earned - used);

    return StreakInfo(
      current: current,
      longest: longest,
      freezeAvailable: freezeAvailable,
    );
  }
}
