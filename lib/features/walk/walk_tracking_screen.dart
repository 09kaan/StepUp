import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'walk_detail_screen.dart';
import 'walk_history_screen.dart';
import 'walk_tracking_controller.dart';

class WalkTrackingScreen extends ConsumerStatefulWidget {
  const WalkTrackingScreen({super.key});

  @override
  ConsumerState<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends ConsumerState<WalkTrackingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      ref.read(walkTrackingControllerProvider.notifier).checkpoint();
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walkTrackingControllerProvider);
    final controller = ref.read(walkTrackingControllerProvider.notifier);

    // controller'daki latlong2 noktalarını Apple Maps LatLng'ine çevir
    final mapPoints = state.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final averageSpeedKmh =
        state.distanceMeters > 0 && state.elapsed.inSeconds > 0
            ? (state.distanceMeters / state.elapsed.inSeconds) * 3.6
            : 0.0;

    final paceFormatted = () {
      if (state.distanceMeters <= 0 || state.elapsed.inSeconds <= 0) {
        return '-';
      }
      final paceSecPerKm =
          (state.elapsed.inSeconds / (state.distanceMeters / 1000)).round();
      final m = paceSecPerKm ~/ 60;
      final s = paceSecPerKm % 60;
      return "$m'${s.toString().padLeft(2, '0')}\"/km";
    }();

    final gradeText = state.isPaused || !state.hasRecentGrade
        ? '-'
        : '%${state.currentGradePercent.toStringAsFixed(1)}';

    final center = mapPoints.isNotEmpty
        ? mapPoints.last
        : const LatLng(41.0082, 28.9784);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yürüyüş Rotası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Geçmiş',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WalkHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28)),
              child: Stack(
                children: [
                  AppleMap(
                    initialCameraPosition:
                        CameraPosition(target: center, zoom: 16),
                    myLocationEnabled: true,
                    trackingMode: state.isTracking
                        ? TrackingMode.follow
                        : TrackingMode.none,
                    polylines: mapPoints.length >= 2
                        ? {
                            Polyline(
                              polylineId: PolylineId('route'),
                              points: mapPoints,
                              color: Colors.blue,
                              width: 5,
                            ),
                          }
                        : <Polyline>{},
                  ),
                  if (state.isPaused && !state.hasRecoveredSession)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: state.isAutoPaused
                              ? Colors.amber.shade900
                              : Colors.orange.shade800,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isAutoPaused
                                  ? Icons.motion_photos_paused
                                  : Icons.pause,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              state.isAutoPaused
                                  ? 'Otomatik Duraklatıldı'
                                  : 'Duraklatıldı',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!state.hasGpsSignal && state.isTracking && !state.isPaused)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gps_off,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'GPS Sinyali Zayıf',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.hasRecoveredSession) ...[
                  Card(
                    color: Colors.orange.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.restore, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Yarım kalan yürüyüş bulundu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(state.distanceMeters / 1000).toStringAsFixed(2)} km'
                            ' • ${state.elapsed.inMinutes} dk (${state.points.length} GPS noktası)',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: controller.discardRecoveredWalk,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                  ),
                                  child: const Text('Sil'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final session = await controller.stop();
                                    if (context.mounted && session != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              WalkDetailScreen(session: session),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Bitir'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: controller.resume,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.brand,
                                  ),
                                  child: const Text('Devam Et'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _WalkStat(
                        value:
                            '${(state.distanceMeters / 1000).toStringAsFixed(2)} km',
                        label: 'Mesafe',
                      ),
                    ),
                    Expanded(
                      child: _WalkStat(
                        value: _fmt(state.elapsed),
                        label: 'Süre',
                      ),
                    ),
                    Expanded(
                      child: _WalkStat(
                        value: averageSpeedKmh > 0
                            ? '${averageSpeedKmh.toStringAsFixed(1)} km/sa'
                            : '-',
                        label: 'Ort. Hız',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _WalkStat(
                        value: paceFormatted,
                        label: 'Ort. Tempo',
                      ),
                    ),
                    Expanded(
                      child: _WalkStat(
                        value:
                            '${state.elevationGainMeters.toStringAsFixed(0)} m',
                        label: 'Tırmanış',
                      ),
                    ),
                    Expanded(
                      child: _WalkStat(
                        value: gradeText,
                        label: 'Güncel Eğim',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (!state.hasRecoveredSession)
                  if (state.isTracking || state.isPaused)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (state.isPaused) {
                                  controller.resume();
                                } else {
                                  controller.pause();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                side: BorderSide(
                                  color: state.isPaused
                                      ? AppColors.brand
                                      : Colors.orange.shade700,
                                  width: 2,
                                ),
                              ),
                              icon: Icon(
                                state.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: state.isPaused
                                    ? AppColors.brand
                                    : Colors.orange.shade700,
                              ),
                              label: Text(
                                state.isPaused ? 'Devam Et' : 'Duraklat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: state.isPaused
                                      ? AppColors.brand
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: () async {
                                final session = await controller.stop();
                                if (context.mounted && session != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          WalkDetailScreen(session: session),
                                    ),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              icon: const Icon(Icons.stop),
                              label: const Text('Bitir'),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: controller.start,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Yürüyüşü Başlat'),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkStat extends StatelessWidget {
  final String value;
  final String label;

  const _WalkStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
