import 'profile_repository.dart';
import 'streak_service.dart';

class AppBadge {
  final String emoji;
  final String title;
  final String description;
  final bool earned;

  const AppBadge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });
}

class BadgeService {
  List<AppBadge> evaluate(ProfileStats s, StreakInfo streak) {
    return [
      AppBadge(
        emoji: '👟',
        title: 'İlk Adım',
        description: 'İlk yürüyüşünü tamamla',
        earned: s.walkCount >= 1,
      ),
      AppBadge(
        emoji: '🚶',
        title: '10 km Kulübü',
        description: 'Toplam 10 km yürü',
        earned: s.totalWalkKm >= 10,
      ),
      AppBadge(
        emoji: '🏃',
        title: '50 km Kulübü',
        description: 'Toplam 50 km yürü',
        earned: s.totalWalkKm >= 50,
      ),
      AppBadge(
        emoji: '🏅',
        title: '100 km Kulübü',
        description: 'Toplam 100 km yürü',
        earned: s.totalWalkKm >= 100,
      ),
      AppBadge(
        emoji: '🔥',
        title: '7 Gün Seri',
        description: '7 günlük seri yakala',
        earned: streak.longest >= 7,
      ),
      AppBadge(
        emoji: '💪',
        title: '30 Gün Seri',
        description: '30 günlük seri yakala',
        earned: streak.longest >= 30,
      ),
      AppBadge(
        emoji: '⛰️',
        title: 'Tırmanışçı',
        description: 'Toplam 500 m tırmanış',
        earned: s.totalElevationMeters >= 500,
      ),
      AppBadge(
        emoji: '✅',
        title: 'Görev Avcısı',
        description: '50 görev tamamla',
        earned: s.completedChallenges >= 50,
      ),
    ];
  }
}
