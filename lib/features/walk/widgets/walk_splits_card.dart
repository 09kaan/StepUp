import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../models/walk_session.dart';
import '../../../theme/app_theme.dart';

class WalkSplitItem {
  final int index;
  final double distanceKm;
  final int durationSeconds;
  final int paceSecondsPerKm;
  final double elevationChangeMeters;

  WalkSplitItem({
    required this.index,
    required this.distanceKm,
    required this.durationSeconds,
    required this.paceSecondsPerKm,
    required this.elevationChangeMeters,
  });

  String get formattedPace {
    if (paceSecondsPerKm <= 0 || paceSecondsPerKm > 3600) return '-';
    final m = paceSecondsPerKm ~/ 60;
    final s = paceSecondsPerKm % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"/km";
  }

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedElevation {
    final sign = elevationChangeMeters >= 0 ? '+' : '';
    return '$sign${elevationChangeMeters.toStringAsFixed(0)} m';
  }
}

class WalkSplitsCard extends StatelessWidget {
  final List<RoutePoint> points;
  final double totalDistanceMeters;
  final int totalMovingSeconds;

  const WalkSplitsCard({
    super.key,
    required this.points,
    required this.totalDistanceMeters,
    required this.totalMovingSeconds,
  });

  List<WalkSplitItem> _computeSplits() {
    if (points.length < 2 || totalDistanceMeters < 500) {
      return [];
    }

    final splits = <WalkSplitItem>[];
    double accumulatedDistM = 0;
    int currentSplitTargetKm = 1;

    RoutePoint splitStartPoint = points.first;
    double splitStartDist = 0;

    for (int i = 1; i < points.length; i++) {
      final pPrev = points[i - 1];
      final pCurr = points[i];
      final d = Geolocator.distanceBetween(
          pPrev.lat, pPrev.lng, pCurr.lat, pCurr.lng);
      accumulatedDistM += d;

      final targetMeters = currentSplitTargetKm * 1000.0;
      if (accumulatedDistM >= targetMeters) {
        // 1 km'lik dilim tamamlandı
        final splitDistM = accumulatedDistM - splitStartDist;
        final splitDistKm = splitDistM / 1000.0;

        int splitSec = 0;
        if (pCurr.movingSeconds > 0 && splitStartPoint.movingSeconds >= 0) {
          splitSec = pCurr.movingSeconds - splitStartPoint.movingSeconds;
        } else if (pCurr.time != null && splitStartPoint.time != null) {
          splitSec = pCurr.time!.difference(splitStartPoint.time!).inSeconds;
        }

        // Eğer süre eksikse orantılı tahmin yap
        if (splitSec <= 0 && totalDistanceMeters > 0) {
          splitSec = ((splitDistM / totalDistanceMeters) * totalMovingSeconds).round();
        }

        final paceSec = splitDistKm > 0 ? (splitSec / splitDistKm).round() : 0;
        final elevDiff = pCurr.altitude - splitStartPoint.altitude;

        splits.add(WalkSplitItem(
          index: currentSplitTargetKm,
          distanceKm: splitDistKm,
          durationSeconds: splitSec,
          paceSecondsPerKm: paceSec,
          elevationChangeMeters: elevDiff,
        ));

        currentSplitTargetKm++;
        splitStartPoint = pCurr;
        splitStartDist = accumulatedDistM;
      }
    }

    // Kalan son kısmi kilometre (örn. 3.42 km'deki 0.42 km)
    final remainingDistM = accumulatedDistM - splitStartDist;
    if (remainingDistM >= 200.0) {
      final splitDistKm = remainingDistM / 1000.0;
      final lastPoint = points.last;

      int splitSec = 0;
      if (lastPoint.movingSeconds > 0 && splitStartPoint.movingSeconds >= 0) {
        splitSec = lastPoint.movingSeconds - splitStartPoint.movingSeconds;
      } else if (lastPoint.time != null && splitStartPoint.time != null) {
        splitSec = lastPoint.time!.difference(splitStartPoint.time!).inSeconds;
      }
      if (splitSec <= 0 && totalDistanceMeters > 0) {
        splitSec = ((remainingDistM / totalDistanceMeters) * totalMovingSeconds).round();
      }

      final paceSec = splitDistKm > 0 ? (splitSec / splitDistKm).round() : 0;
      final elevDiff = lastPoint.altitude - splitStartPoint.altitude;

      splits.add(WalkSplitItem(
        index: currentSplitTargetKm,
        distanceKm: splitDistKm,
        durationSeconds: splitSec,
        paceSecondsPerKm: paceSec,
        elevationChangeMeters: elevDiff,
      ));
    }

    return splits;
  }

  @override
  Widget build(BuildContext context) {
    final splits = _computeSplits();
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    // En hızlı ve en yavaş tempoyu bularak bağıl tempo çubuğu çiz
    final validPaces = splits
        .map((s) => s.paceSecondsPerKm)
        .where((p) => p > 0)
        .toList();
    final fastestPace = validPaces.isNotEmpty ? validPaces.reduce((a, b) => a < b ? a : b) : 1;
    final slowestPace = validPaces.isNotEmpty ? validPaces.reduce((a, b) => a > b ? a : b) : 1;

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
                child: const Icon(Icons.splitscreen,
                    size: 18, color: AppColors.brand),
              ),
              const SizedBox(width: 8),
              const Text(
                'Kilometre Bölümleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${splits.length} Bölüm',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Tablo Başlıkları
          Row(
            children: [
              const SizedBox(
                width: 44,
                child: Text('KM',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted)),
              ),
              const Expanded(
                flex: 4,
                child: Text('TEMPO',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted)),
              ),
              const Expanded(
                flex: 2,
                child: Text('SÜRE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted)),
              ),
              const Expanded(
                flex: 2,
                child: Text('YÜKSELTİ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Her Split Satırı
          ...splits.map((split) {
            final isFastest = split.paceSecondsPerKm == fastestPace;

            // Çubuk doluluk oranı (hızlı olan daha dolu)
            double barRatio = 0.5;
            if (slowestPace > fastestPace) {
              barRatio = 0.4 +
                  (0.6 *
                      (slowestPace - split.paceSecondsPerKm) /
                      (slowestPace - fastestPace));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      split.distanceKm < 0.95
                          ? '${split.distanceKm.toStringAsFixed(2)}k'
                          : '${split.index}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isFastest ? AppColors.brand : Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          split.formattedPace,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isFastest
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isFastest ? AppColors.brand : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 5,
                            width: 110 * barRatio.clamp(0.2, 1.0),
                            color: isFastest
                                ? AppColors.brand
                                : Colors.blueGrey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      split.formattedDuration,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      split.formattedElevation,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: split.elevationChangeMeters > 0
                            ? Colors.red.shade600
                            : (split.elevationChangeMeters < 0
                                ? Colors.blue.shade600
                                : Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
