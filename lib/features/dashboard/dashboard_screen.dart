import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final todayAsync = ref.watch(todayActivityProvider);
    final statusAsync = ref.watch(pedestrianStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bugün')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(todayActivityProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            todayAsync.when(
              data: (a) => Center(
                child: _GoalRing(
                  steps: a.steps,
                  goalSteps: a.goalSteps,
                  distanceMeters: a.distanceMeters,
                  activeCalories: a.activeCalories,
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sağlık verisi alınamadı. İzin verildiğinden emin ol.\n$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: statusAsync.when(
                data: (status) => Chip(
                  avatar: Icon(
                    status == 'walking'
                        ? Icons.directions_walk
                        : Icons.accessibility_new,
                    size: 18,
                  ),
                  label: Text(status == 'walking' ? 'Yürüyor' : 'Duruyor'),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final int steps;
  final int goalSteps;
  final double distanceMeters;
  final double activeCalories;

  const _GoalRing({
    required this.steps,
    required this.goalSteps,
    required this.distanceMeters,
    required this.activeCalories,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction =
        goalSteps > 0 ? (steps / goalSteps).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 14,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$steps',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                  ),
                  Text('/ $goalSteps adım'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(
              label: 'Mesafe',
              value: '${(distanceMeters / 1000).toStringAsFixed(2)} km',
            ),
            _Stat(
              label: 'Kalori',
              value: '${activeCalories.toStringAsFixed(0)} kcal',
            ),
            _Stat(
              label: 'Hedef',
              value: '${(fraction * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
