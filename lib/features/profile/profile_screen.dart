import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/badge_service.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_controller.dart'; // streakProvider
import 'profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);
    final streakAsync = ref.watch(streakProvider);
    final badgesAsync = ref.watch(badgesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileStatsProvider);
          ref.invalidate(badgesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            statsAsync.when(
              loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('İstatistik hatası: $e'),
              data: (s) {
                final streak = streakAsync.asData?.value;
                final items = [
                  _StatData('Toplam mesafe',
                      '${s.totalWalkKm.toStringAsFixed(1)} km', Icons.straighten),
                  _StatData('Yürüyüş sayısı', '${s.walkCount}',
                      Icons.directions_walk),
                  _StatData('Toplam tırmanış',
                      '${s.totalElevationMeters.toStringAsFixed(0)} m',
                      Icons.terrain),
                  _StatData('Tamamlanan görev', '${s.completedChallenges}',
                      Icons.flag),
                  _StatData('Güncel seri', '${streak?.current ?? 0} gün',
                      Icons.local_fire_department),
                  _StatData('En uzun seri', '${streak?.longest ?? 0} gün',
                      Icons.emoji_events),
                ];

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.7,
                  children: items.map((d) => _StatTile(data: d)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const SectionHeader('Rozetler'),
            const SizedBox(height: 12),
            badgesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Rozet hatası: $e'),
              data: (badges) => GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 8,
                childAspectRatio: 0.74,
                children:
                    badges.map((b) => _BadgeTile(badge: b)).toList(),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Günlük hatırlatma (19:00)'),
              subtitle: const Text('Her akşam yürüyüş hatırlatması'),
              trailing: TextButton(
                onPressed: () async {
                  await NotificationService.instance.showTestNow();
                },
                child: const Text('Test et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  _StatData(this.label, this.value, this.icon);
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 20, color: AppColors.brand),
          const SizedBox(height: 8),
          Text(data.value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(data.label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AppBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;

    return Tooltip(
      message: '${badge.title}\n${badge.description}',
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: earned
                  ? AppColors.brand.withOpacity(0.12)
                  : const Color(0xFFEDEFEE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                badge.icon,
                size: 26,
                color: earned ? AppColors.brand : Colors.black26,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: earned ? FontWeight.w600 : FontWeight.w400,
              color: earned ? Colors.black87 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
