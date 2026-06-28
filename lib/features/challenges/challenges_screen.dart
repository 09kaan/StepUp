import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/challenge.dart';
import 'challenge_controller.dart';

String _unitLabel(ChallengeUnit u) {
  switch (u) {
    case ChallengeUnit.reps:
      return 'tekrar';
    case ChallengeUnit.steps:
      return 'adım';
    case ChallengeUnit.km:
      return 'km';
    case ChallengeUnit.minutes:
      return 'dk';
  }
}

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(todayChallengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Görevler')),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (list) {
          final done = list.where((c) => c.isCompleted).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bugün',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('$done / ${list.length} tamam',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final unit = _unitLabel(c.unit);

                    if (c.verification == VerificationKind.manual) {
                      return CheckboxListTile(
                        value: c.isCompleted,
                        title: Text(c.title),
                        subtitle: Text(
                            '${c.goalValue.toStringAsFixed(0)} $unit • elle onay'),
                        onChanged: (v) async {
                          await ref
                              .read(challengeRepoProvider)
                              .setManualComplete(c.id, v ?? false);
                          ref.invalidate(todayChallengesProvider);
                        },
                      );
                    }

                    // Otomatik görev (ör. km): salt okunur ilerleme
                    return ListTile(
                      leading: Icon(
                        c.isCompleted
                            ? Icons.check_circle
                            : Icons.directions_walk,
                        color: c.isCompleted ? Colors.green : null,
                      ),
                      title: Text(c.title),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(
                            value: c.progressFraction),
                      ),
                      trailing: Text(
                          '${c.progress.toStringAsFixed(1)}/${c.goalValue.toStringAsFixed(0)} $unit'),
                    );
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
