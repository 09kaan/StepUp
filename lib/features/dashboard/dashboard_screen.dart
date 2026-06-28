import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_card.dart';
import '../../theme/app_theme.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(todayActivityProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bugün')),
      body: activityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (a) {
          final steps = a.steps;
          final goal = a.goalSteps;
          final km = a.distanceMeters / 1000;
          final kcal = a.activeCalories;
          final pct =
              goal > 0 ? ((steps / goal) * 100).clamp(0, 100).round() : 0;
          final goalReached = a.goalReached;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const SizedBox(height: 8),
              Center(child: _GoalRing(steps: steps, goal: goal)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.straighten,
                      value: '${km.toStringAsFixed(2)} km',
                      label: 'Mesafe',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.local_fire_department,
                      value: '${kcal.toStringAsFixed(0)} kcal',
                      label: 'Kalori',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.flag,
                      value: '%$pct',
                      label: 'Hedef',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              streakAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (s) => _StreakCard(
                  current: s.current,
                  longest: s.longest,
                  freeze: s.freezeAvailable,
                  canProtect: s.freezeAvailable > 0 && !goalReached,
                  onProtect: () async {
                    await ref
                        .read(dailyActivityRepoProvider)
                        .setProtected(DateTime.now(), true);
                    ref.invalidate(streakProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final int steps;
  final int goal;
  const _GoalRing({required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: CustomPaint(
        painter: _RingPainter(
            goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$steps',
                  style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand)),
              Text('/ $goal adım',
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 12;
    const stroke = 18.0;

    final bg = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final fg = Paint()
      ..shader = const SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: [AppColors.brandSoft, AppColors.brand],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -1.5708, 6.2832 * fraction, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.brand),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int current;
  final int longest;
  final int freeze;
  final bool canProtect;
  final VoidCallback onProtect;

  const _StreakCard({
    required this.current,
    required this.longest,
    required this.freeze,
    required this.canProtect,
    required this.onProtect,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakStat(
                  icon: Icons.local_fire_department,
                  value: '$current',
                  label: 'Güncel seri'),
              _StreakStat(
                  icon: Icons.emoji_events,
                  value: '$longest',
                  label: 'En uzun'),
              _StreakStat(
                  icon: Icons.ac_unit,
                  value: '$freeze',
                  label: 'Telafi hakkı'),
            ],
          ),
          if (canProtect) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onProtect,
                icon: const Icon(Icons.ac_unit),
                label: const Text('Bugünü telafi günü yap'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StreakStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 26, color: AppColors.brand),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
