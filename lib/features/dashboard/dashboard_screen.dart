import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/suggestion_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_theme.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ekran açıkken her 20 sn'de bir sağlık verisini tazele (canlı dolum).
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arka plandan öne gelince anında tazele.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    ref.invalidate(todayActivityProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(goalSuggestionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(todayActivityProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bugün')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
          await ref.read(todayActivityProvider.future);
        },
        child: activityAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 240),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(
                child: Text('Sağlık verisi alınamadı.\n$e',
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (a) {
            final steps = a.steps;
            final goal = a.goalSteps;
            final km = a.distanceMeters / 1000;
            final kcal = a.activeCalories;
            final pct =
                goal > 0 ? ((steps / goal) * 100).clamp(0, 100).round() : 0;
            final goalReached = a.goalReached;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                const SizedBox(height: 16),
                ref.watch(goalSuggestionProvider).maybeWhen(
                      data: (sug) => sug == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: _SuggestionCard(
                                suggestion: sug,
                                onAccept: () async {
                                  await ref
                                      .read(settingsRepoProvider)
                                      .setStepGoal(sug.suggestedGoal);
                                  _refresh();
                                  ref.invalidate(goalSuggestionProvider);
                                },
                              ),
                            ),
                      orElse: () => const SizedBox.shrink(),
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

class _SuggestionCard extends StatelessWidget {
  final GoalSuggestion suggestion;
  final Future<void> Function() onAccept;

  const _SuggestionCard(
      {required this.suggestion, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: AppColors.accent),
              SizedBox(width: 8),
              Expanded(
                child: Text('Hedefini yükseltmeye hazırsın',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Son 7 gündür ${suggestion.currentGoal} adım hedefini rahatça '
            'tutturuyorsun. ${suggestion.suggestedGoal} adıma çıkaralım mı?',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAccept,
              child: Text('${suggestion.suggestedGoal} adıma çıkar'),
            ),
          ),
        ],
      ),
    );
  }
}
