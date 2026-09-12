import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class DurationBreakdownCard extends StatelessWidget {
  final int movingSeconds;
  final DateTime startTime;
  final DateTime? endTime;

  const DurationBreakdownCard({
    super.key,
    required this.movingSeconds,
    required this.startTime,
    required this.endTime,
  });

  String _fmt(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}s ${m}dk';
    if (m > 0) return '${m}dk ${s}sn';
    return '${s}sn';
  }

  @override
  Widget build(BuildContext context) {
    final totalElapsedSeconds = endTime != null
        ? endTime!.difference(startTime).inSeconds
        : movingSeconds;

    final actualMoving = movingSeconds > 0
        ? movingSeconds
        : totalElapsedSeconds;

    final pausedSeconds = (totalElapsedSeconds - actualMoving).clamp(0, 86400 * 7);
    final movingRatio = totalElapsedSeconds > 0
        ? (actualMoving / totalElapsedSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.av_timer,
                    size: 18, color: AppColors.brand),
              ),
              const SizedBox(width: 8),
              const Text(
                'Süre Dağılımı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '%${(movingRatio * 100).toStringAsFixed(0)} Hareket',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Hareket vs Duraklama Oran Çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    flex: (movingRatio * 1000).round().clamp(1, 1000),
                    child: Container(color: AppColors.brand),
                  ),
                  if (pausedSeconds > 0)
                    Expanded(
                      flex: ((1.0 - movingRatio) * 1000).round().clamp(1, 1000),
                      child: Container(color: Colors.orange.shade400),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DurationCol(
                label: 'Hareket Süresi',
                value: _fmt(actualMoving),
                dotColor: AppColors.brand,
              ),
              _DurationCol(
                label: 'Toplam Süre',
                value: _fmt(totalElapsedSeconds),
                dotColor: Colors.blueGrey,
              ),
              _DurationCol(
                label: 'Duraklama',
                value: _fmt(pausedSeconds),
                dotColor: Colors.orange.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationCol extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;

  const _DurationCol({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
