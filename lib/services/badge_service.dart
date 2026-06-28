import 'package:flutter/material.dart';
import 'profile_repository.dart';
import 'streak_service.dart';

class AppBadge {
  final IconData icon;
  final String title;
  final String description;
  final bool earned;

  const AppBadge({
    required this.icon,
    required this.title,
    required this.description,
    required this.earned,
  });
}

class BadgeService {
  List<AppBadge> evaluate(ProfileStats s, StreakInfo streak) {
    return [
      AppBadge(
        icon: Icons.flag,
        title: 'İlk Adım',
        description: 'İlk yürüyüşünü tamamla',
        earned: s.walkCount >= 1,
      ),
      AppBadge(
        icon: Icons.directions_walk,
        title: '10 km Kulübü',
        description: 'Toplam 10 km yürü',
        earned: s.totalWalkKm >= 10,
      ),
      AppBadge(
        icon: Icons.directions_run,
        title: '50 km Kulübü',
        description: 'Toplam 50 km yürü',
        earned: s.totalWalkKm >= 50,
      ),
      AppBadge(
        icon: Icons.military_tech,
        title: '100 km Kulübü',
        description: 'Toplam 100 km yürü',
        earned: s.totalWalkKm >= 100,
      ),
      AppBadge(
        icon: Icons.local_fire_department,
        title: '7 Gün Seri',
        description: '7 günlük seri yakala',
        earned: streak.longest >= 7,
      ),
      AppBadge(
        icon: Icons.fitness_center,
        title: '30 Gün Seri',
        description: '30 günlük seri yakala',
        earned: streak.longest >= 30,
      ),
      AppBadge(
        icon: Icons.terrain,
        title: 'Tırmanışçı',
        description: 'Toplam 500 m tırmanış',
        earned: s.totalElevationMeters >= 500,
      ),
      AppBadge(
        icon: Icons.check_circle,
        title: 'Görev Avcısı',
        description: '50 görev tamamla',
        earned: s.completedChallenges >= 50,
      ),
    ];
  }
}
