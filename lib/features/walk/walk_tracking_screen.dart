import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'walk_history_screen.dart';
import 'walk_tracking_controller.dart';

class WalkTrackingScreen extends ConsumerWidget {
  const WalkTrackingScreen({super.key});

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walkTrackingControllerProvider);
    final controller = ref.read(walkTrackingControllerProvider.notifier);

    // controller'daki latlong2 noktalarını Apple Maps LatLng'ine çevir
    final mapPoints = state.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

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
              child: AppleMap(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(state.error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WalkStat(
                        value:
                            '${(state.distanceMeters / 1000).toStringAsFixed(2)} km',
                        label: 'Mesafe'),
                    _WalkStat(
                        value: _fmt(state.elapsed), label: 'Süre'),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: state.isTracking
                          ? Colors.red.shade600
                          : AppColors.brand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      if (state.isTracking) {
                        final s = await controller.stop();
                        if (context.mounted && s != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Yürüyüş kaydedildi: ${(s.distanceMeters / 1000).toStringAsFixed(2)} km'),
                            ),
                          );
                        }
                      } else {
                        controller.start();
                      }
                    },
                    icon: Icon(state.isTracking
                        ? Icons.stop
                        : Icons.play_arrow),
                    label: Text(state.isTracking
                        ? 'Yürüyüşü Bitir'
                        : 'Yürüyüşü Başlat'),
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
        Text(value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}
