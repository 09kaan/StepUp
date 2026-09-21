import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../main.dart'; // isarProvider
import '../../models/walk_session.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import 'services/gpx_export_service.dart';
import 'widgets/duration_breakdown_card.dart';
import 'widgets/elevation_profile_card.dart';
import 'widgets/walk_splits_card.dart';

class WalkDetailScreen extends ConsumerStatefulWidget {
  final WalkSession session;
  const WalkDetailScreen({super.key, required this.session});

  @override
  ConsumerState<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends ConsumerState<WalkDetailScreen> {
  late WalkSession _session;
  bool _isExportingGpx = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  LatLngBounds _bounds(List<LatLng> pts) {
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Polyline> _buildGradePolylines(List<RoutePoint> rawPoints) {
    if (rawPoints.length < 2) return {};

    // 1. İrtifaları 3 noktalı hareketli ortalama ile süz (GPS dikey gürültüsünü engeller)
    final smoothedAlts = <double>[];
    for (int i = 0; i < rawPoints.length; i++) {
      double sum = rawPoints[i].altitude;
      int count = 1;
      if (i > 0) {
        sum += rawPoints[i - 1].altitude;
        count++;
      }
      if (i < rawPoints.length - 1) {
        sum += rawPoints[i + 1].altitude;
        count++;
      }
      smoothedAlts.add(sum / count);
    }

    final polylines = <Polyline>{};
    List<LatLng> currentBatch = [LatLng(rawPoints[0].lat, rawPoints[0].lng)];
    Color? currentColor;
    int polylineIndex = 0;

    for (int i = 1; i < rawPoints.length; i++) {
      final p1 = rawPoints[i - 1];
      final p2 = rawPoints[i];

      final d = Geolocator.distanceBetween(p1.lat, p1.lng, p2.lat, p2.lng);
      final pt = LatLng(p2.lat, p2.lng);

      // GPS Boşluğu / Işınlanma Filtresi: Uzun süreli kesintilerde veya mantıksız sıçramalarda
      // araya düz çizgi çekmek yerine rotayı yeni bir parça olarak başlat.
      final timeDelta = (p1.time != null && p2.time != null)
          ? p2.time!.difference(p1.time!).inSeconds.abs()
          : 0;
      final isGap = p2.startsNewSegment || (timeDelta > 45 && d > 30) || d > 200;

      if (isGap) {
        if (currentBatch.length >= 2 && currentColor != null) {
          polylines.add(
            Polyline(
              polylineId: PolylineId('batch_${polylineIndex++}'),
              points: List.of(currentBatch),
              color: currentColor,
              width: 5,
            ),
          );
        }
        currentBatch = [pt];
        currentColor = null;
        continue;
      }

      final altDiff = smoothedAlts[i] - smoothedAlts[i - 1];

      // Gürültü Filtresi: Çok kısa mesafeler veya düşük dikey doğrulukta eğim 0 kabul edilir
      double grade = 0.0;
      final isAccurate =
          (p1.altitudeAccuracy > 0 && p1.altitudeAccuracy <= 15) &&
              (p2.altitudeAccuracy > 0 && p2.altitudeAccuracy <= 15);
      if (d >= 8.0 && isAccurate) {
        grade = (altDiff / d) * 100;
      }

      Color segmentColor;
      if (grade < -1.0) {
        segmentColor = const Color(0xFF3B82F6); // İniş (Mavi)
      } else if (grade <= 3.0) {
        segmentColor = const Color(0xFF10B981); // Düz / Çok Hafif (Yeşil)
      } else if (grade <= 6.0) {
        segmentColor = const Color(0xFFF59E0B); // Hafif Yokuş (Sarı)
      } else if (grade <= 10.0) {
        segmentColor = const Color(0xFFF97316); // Orta Yokuş (Turuncu)
      } else {
        segmentColor = const Color(0xFFEF4444); // Dik Yokuş (Kırmızı)
      }

      if (currentColor == null) {
        currentColor = segmentColor;
        currentBatch.add(pt);
      } else if (currentColor == segmentColor) {
        currentBatch.add(pt);
      } else {
        // Renk değişti: Mevcut grubu tek bir polyline olarak kaydet
        polylines.add(
          Polyline(
            polylineId: PolylineId('batch_${polylineIndex++}'),
            points: List.of(currentBatch),
            color: currentColor,
            width: 5,
          ),
        );
        // Süreklilik için bir önceki son nokta yeni grubun ilk noktası olur
        currentBatch = [currentBatch.last, pt];
        currentColor = segmentColor;
      }
    }

    // Kalan son grubu ekle
    if (currentBatch.length >= 2 && currentColor != null) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('batch_${polylineIndex++}'),
          points: List.of(currentBatch),
          color: currentColor,
          width: 5,
        ),
      );
    }

    return polylines;
  }

  Future<void> _exportGpx() async {
    if (_isExportingGpx) return;
    setState(() => _isExportingGpx = true);

    try {
      await GpxExportService.exportAndShare(_session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPX dışa aktarma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingGpx = false);
      }
    }
  }

  Future<void> _editTitle() async {
    final ctrl =
        TextEditingController(text: _session.title ?? _session.displayTitle);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yürüyüş Adı'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn: Kadıköy Sahil Yürüyüşü',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (confirmed == true && ctrl.text.trim().isNotEmpty) {
      final newTitle = ctrl.text.trim();
      final isar = ref.read(isarProvider);
      await isar.writeTxn(() async {
        _session.title = newTitle;
        await isar.walkSessions.put(_session);
      });
      if (mounted) {
        setState(() {});
      }
    }
    ctrl.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yürüyüşü sil'),
        content: const Text(
          'Bu yürüyüş kaydı kalıcı olarak silinecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.walkSessions.delete(_session.id));
    unawaited(NotificationService.instance.syncReminderWithTodayActivity(isar));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}s ${m}dk';
    if (m > 0) return '${m}dk ${s}sn';
    return '${s}sn';
  }

  @override
  Widget build(BuildContext context) {
    final points =
        _session.points.map((p) => LatLng(p.lat, p.lng)).toList();
    final hasRoute = points.length >= 2;
    final center = points.isNotEmpty
        ? points[points.length ~/ 2]
        : const LatLng(41.0082, 28.9784);

    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
        .format(_session.startTime);

    final polylines = _buildGradePolylines(_session.points);

    final totalElapsedSeconds = _session.endTime != null
        ? _session.endTime!.difference(_session.startTime).inSeconds
        : _session.durationSeconds;
    final pausedSeconds =
        (totalElapsedSeconds - _session.durationSeconds).clamp(0, 86400 * 7);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editTitle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _session.displayTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: _isExportingGpx
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            tooltip: 'GPX Dışa Aktar',
            onPressed: _exportGpx,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Harita Bölümü
            SizedBox(
              height: 280,
              width: double.infinity,
              child: hasRoute
                  ? AppleMap(
                      initialCameraPosition:
                          CameraPosition(target: center, zoom: 15),
                      onMapCreated: (controller) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          controller.animateCamera(
                            CameraUpdate.newLatLngBounds(_bounds(points), 50),
                          );
                        });
                      },
                      polylines: polylines,
                      annotations: {
                        Annotation(
                          annotationId: AnnotationId('start'),
                          position: points.first,
                          infoWindow: const InfoWindow(title: 'Başlangıç'),
                        ),
                        Annotation(
                          annotationId: AnnotationId('end'),
                          position: points.last,
                          infoWindow: const InfoWindow(title: 'Bitiş'),
                        ),
                      },
                    )
                  : Container(
                      color: const Color(0xFFF4F7F6),
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Bu yürüyüş için kayıtlı rota koordinatı yok.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
            ),

            // 2. Eğime Göre Renkli Lejant Çubuğu
            if (hasRoute) _buildGradeLegend(),

            // 3. İçerik ve Detay Analizleri
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: _editTitle,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            'Adı Değiştir',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 1. Sıra: Mesafe, Hareket Süresi, Ortalama Tempo
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Mesafe',
                          value:
                              '${(_session.distanceMeters / 1000).toStringAsFixed(2)} km',
                          icon: Icons.straighten,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Hareket Süresi',
                          value: _formatDuration(_session.durationSeconds),
                          icon: Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Ort. Tempo',
                          value: _session.paceFormatted,
                          icon: Icons.speed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 2. Sıra: Ortalama Hız, Tırmanış, Çıkış Eğimi
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Ort. Hız',
                          value: _session.averageSpeedFormatted,
                          icon: Icons.speed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Tırmanış',
                          value:
                              '${_session.elevationGainMeters.toStringAsFixed(0)} m',
                          icon: Icons.terrain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Çıkış Eğimi',
                          value:
                              '%${_session.avgGradePercent.toStringAsFixed(1)}',
                          icon: Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 3. Sıra: Kalori, Maksimum Rakım, Duraklama Süresi
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Kalori',
                          value:
                              '${_session.caloriesEstimated.toStringAsFixed(0)} kcal',
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Maks. Rakım',
                          value: _session.maxAltitude > 0
                              ? '${_session.maxAltitude.toStringAsFixed(0)} m'
                              : '-',
                          icon: Icons.landscape,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricTile(
                          label: 'Duraklama',
                          value: _formatDuration(pausedSeconds),
                          icon: Icons.pause_circle_outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 4. Süre Dağılımı (Hareket vs Toplam vs Duraklama)
                  DurationBreakdownCard(
                    movingSeconds: _session.durationSeconds,
                    startTime: _session.startTime,
                    endTime: _session.endTime,
                  ),

                  // 5. Yükseklik Profili Grafiği
                  ElevationProfileCard(session: _session),

                  // 6. Kilometre Bölümleri (Strava Splits)
                  WalkSplitsCard(
                    points: _session.points,
                    totalDistanceMeters: _session.distanceMeters,
                    totalMovingSeconds: _session.durationSeconds,
                  ),

                  const SizedBox(height: 12),

                  // 7. GPX Dışa Aktarma Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        side: const BorderSide(color: AppColors.brand),
                      ),
                      onPressed: _exportGpx,
                      icon: const Icon(Icons.share, color: AppColors.brand),
                      label: const Text(
                        'Rotayı GPX Olarak Paylaş',
                        style: TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendDot(color: Color(0xFF3B82F6), label: 'İniş'),
          _LegendDot(color: Color(0xFF10B981), label: '%0-3 Düz'),
          _LegendDot(color: Color(0xFFF59E0B), label: '%3-6'),
          _LegendDot(color: Color(0xFFF97316), label: '%6-10'),
          _LegendDot(color: Color(0xFFEF4444), label: '%10+ Dik'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
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
      ),
    );
  }
}
