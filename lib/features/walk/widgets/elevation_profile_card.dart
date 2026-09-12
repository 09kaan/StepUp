import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../models/walk_session.dart';
import '../../../theme/app_theme.dart';

class ElevationProfileCard extends StatelessWidget {
  final WalkSession session;

  const ElevationProfileCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final points = session.points;
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    // Mesafe ve yükseklik serilerini hazırla
    final dists = <double>[0.0];
    final alts = <double>[points.first.altitude];
    double totalDistM = 0;
    double maxGrade = 0;

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final d = Geolocator.distanceBetween(p1.lat, p1.lng, p2.lat, p2.lng);
      totalDistM += d;
      dists.add(totalDistM / 1000.0); // km cinsinden
      alts.add(p2.altitude);

      final diff = p2.altitude - p1.altitude;
      if (d >= 8.0 && p1.altitudeAccuracy > 0 && p2.altitudeAccuracy > 0) {
        final g = (diff / d) * 100;
        if (g > maxGrade) maxGrade = g;
      }
    }

    // Hareketli ortalama ile grafiği yumuşat (smoothing)
    final smoothedAlts = <double>[];
    const windowSize = 3;
    for (int i = 0; i < alts.length; i++) {
      int count = 0;
      double sum = 0;
      for (int w = -windowSize; w <= windowSize; w++) {
        final idx = i + w;
        if (idx >= 0 && idx < alts.length) {
          sum += alts[idx];
          count++;
        }
      }
      smoothedAlts.add(sum / count);
    }

    // Gerçek min ve maks irtifa değerleri
    final actualMinAlt = smoothedAlts.reduce(math.min);
    final actualMaxAlt = smoothedAlts.reduce(math.max);

    // Grafik ölçeği: 10m altındaki irtifa farklarında eğri ortalanarak çizilir
    double chartMinAlt = actualMinAlt;
    double chartMaxAlt = actualMaxAlt;

    if (chartMaxAlt - chartMinAlt < 10.0) {
      final center = (chartMaxAlt + chartMinAlt) / 2;
      chartMinAlt = center - 5.0;
      chartMaxAlt = center + 5.0;
    }

    // İniş hesabı: 1.5m ölü bölge + 5m yatay hareket filtresi (sahte salınımları engeller)
    double loss = 0;
    double lastValidAlt = points.first.altitude;
    double lastHPosLat = points.first.lat;
    double lastHPosLng = points.first.lng;

    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      final hDist =
          Geolocator.distanceBetween(lastHPosLat, lastHPosLng, p.lat, p.lng);
      final altDiff = p.altitude - lastValidAlt;

      if (altDiff <= -1.5 && hDist >= 5.0) {
        loss += altDiff.abs();
        lastValidAlt = p.altitude;
        lastHPosLat = p.lat;
        lastHPosLng = p.lng;
      } else if (altDiff >= 1.5 && hDist >= 5.0) {
        lastValidAlt = p.altitude;
        lastHPosLat = p.lat;
        lastHPosLng = p.lng;
      }
    }

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
                child: const Icon(Icons.show_chart,
                    size: 18, color: AppColors.brand),
              ),
              const SizedBox(width: 8),
              const Text(
                'Yükseklik Profili',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${dists.last.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: _ElevationChartPainter(
                distances: dists,
                altitudes: smoothedAlts,
                minAlt: chartMinAlt,
                maxAlt: chartMaxAlt,
                chartColor: AppColors.brand,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                label: 'En Düşük',
                value: '${actualMinAlt.toStringAsFixed(0)} m',
                icon: Icons.arrow_downward,
                color: Colors.blue.shade600,
              ),
              _MiniStat(
                label: 'En Yüksek',
                value: '${actualMaxAlt.toStringAsFixed(0)} m',
                icon: Icons.arrow_upward,
                color: Colors.red.shade600,
              ),
              _MiniStat(
                label: 'Çıkış',
                value: '+${session.elevationGainMeters.toStringAsFixed(0)} m',
                icon: Icons.north_east,
                color: Colors.green.shade600,
              ),
              _MiniStat(
                label: 'İniş',
                value: '-${loss.toStringAsFixed(0)} m',
                icon: Icons.south_east,
                color: Colors.teal.shade600,
              ),
              _MiniStat(
                label: 'Maks Eğim',
                value: '%${maxGrade.clamp(0, 35).toStringAsFixed(0)}',
                icon: Icons.trending_up,
                color: Colors.orange.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ElevationChartPainter extends CustomPainter {
  final List<double> distances;
  final List<double> altitudes;
  final double minAlt;
  final double maxAlt;
  final Color chartColor;

  _ElevationChartPainter({
    required this.distances,
    required this.altitudes,
    required this.minAlt,
    required this.maxAlt,
    required this.chartColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (distances.length < 2) return;

    final maxDist = distances.last;
    if (maxDist <= 0) return;

    final altRange = (maxAlt - minAlt).clamp(1.0, 10000.0);
    const topPadding = 12.0;
    const bottomPadding = 20.0;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (int step = 0; step <= 2; step++) {
      final yNorm = step / 2.0;
      final y = topPadding + (chartHeight * yNorm);
      final altVal = maxAlt - (altRange * yNorm);

      canvas.drawLine(Offset(28, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '${altVal.toStringAsFixed(0)}m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - (tp.height / 2)));
    }

    final startX = 32.0;
    final usableWidth = size.width - startX;

    final path = Path();
    final fillPath = Path();

    double getX(int i) => startX + ((distances[i] / maxDist) * usableWidth);
    double getY(int i) {
      final norm = (altitudes[i] - minAlt) / altRange;
      return topPadding + chartHeight * (1.0 - norm);
    }

    path.moveTo(getX(0), getY(0));
    fillPath.moveTo(getX(0), topPadding + chartHeight);
    fillPath.lineTo(getX(0), getY(0));

    for (int i = 1; i < distances.length; i++) {
      final x0 = getX(i - 1);
      final y0 = getY(i - 1);
      final x1 = getX(i);
      final y1 = getY(i);

      final cx = (x0 + x1) / 2;
      path.cubicTo(cx, y0, cx, y1, x1, y1);
      fillPath.cubicTo(cx, y0, cx, y1, x1, y1);
    }

    fillPath.lineTo(getX(distances.length - 1), topPadding + chartHeight);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        chartColor.withValues(alpha: 0.35),
        chartColor.withValues(alpha: 0.03),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(startX, topPadding, usableWidth, chartHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = chartColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final tpStart = TextPainter(
      text: TextSpan(text: '0 km', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpStart.paint(canvas, Offset(startX, size.height - tpStart.height));

    final tpEnd = TextPainter(
      text: TextSpan(
          text: '${maxDist.toStringAsFixed(1)} km', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpEnd.paint(
        canvas, Offset(size.width - tpEnd.width, size.height - tpEnd.height));
  }

  @override
  bool shouldRepaint(covariant _ElevationChartPainter oldDelegate) {
    return oldDelegate.distances != distances ||
        oldDelegate.altitudes != altitudes;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
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
