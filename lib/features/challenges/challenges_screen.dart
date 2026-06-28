import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/challenge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';
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

IconData _iconFor(Challenge c) {
  if (c.unit == ChallengeUnit.km || c.unit == ChallengeUnit.steps) {
    return Icons.directions_walk;
  }
  return Icons.fitness_center;
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SectionHeader('Bugün', trailing: '$done / ${list.length} tamam'),
              const SizedBox(height: 4),
              ...list.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChallengeTile(challenge: c),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _ChallengeTile extends ConsumerWidget {
  final Challenge challenge;
  const _ChallengeTile({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = challenge;
    final unit = _unitLabel(c.unit);
    final manual = c.verification == VerificationKind.manual;

    return AppCard(
      onTap: manual
          ? () async {
              await ref
                  .read(challengeRepoProvider)
                  .setManualComplete(c.id, !c.isCompleted);
              ref.invalidate(todayChallengesProvider);
            }
          : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brand
                  .withOpacity(c.isCompleted ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              c.isCompleted ? Icons.check_rounded : _iconFor(c),
              color: AppColors.brand,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                if (manual)
                  Text('${c.goalValue.toStringAsFixed(0)} $unit • elle onay',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted))
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: c.progressFraction,
                      minHeight: 8,
                      backgroundColor: AppColors.track,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${c.progress.toStringAsFixed(1)}/${c.goalValue.toStringAsFixed(0)} $unit',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          if (manual)
            Icon(
              c.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: c.isCompleted ? AppColors.brand : Colors.black26,
            ),
        ],
      ),
    );
  }
}
