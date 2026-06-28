import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/dashboard_controller.dart'; // streakProvider
import '../../services/badge_service.dart';
import '../../services/notification_service.dart';
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
          padding: const EdgeInsets.all(16),
          children: [
            // İstatistikler
            statsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator())),
              error: (e, _) => Text('İstatistik hatası: $e'),
              data: (s) {
                final streak = streakAsync.asData?.value;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.6,
                  children: [
                    _StatTile(
                      label: 'Toplam mesafe',
                      value: '${s.totalWalkKm.toStringAsFixed(1)} km'),
                    _StatTile(
                      label: 'Yürüyüş sayısı',
                      value: '${s.walkCount}'),
                    _StatTile(
                      label: 'Toplam tırmanış',
                      value: '${s.totalElevationMeters.toStringAsFixed(0)} m'),
                    _StatTile(
                      label: 'Tamamlanan görev',
                      value: '${s.completedChallenges}'),
                    _StatTile(
                      label: 'Güncel seri',
                      value: '${streak?.current ?? 0} gün'),
                    _StatTile(
                      label: 'En uzun seri',
                      value: '${streak?.longest ?? 0} gün'),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Rozetler',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            badgesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Rozet hatası: $e'),
              data: (badges) => GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: badges
                    .map((b) => _BadgeTile(badge: b))
                    .toList(),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AppBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${badge.title}\n${badge.description}',
      child: Opacity(
        opacity: badge.earned ? 1 : 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
