import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'walk_tracking_controller.dart';

// OSM tile şablonu. {z}/{x}/{y} flutter_map tarafından doldurulur.
const String _osmTileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

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

    final center =
        state.points.isNotEmpty ? state.points.last : const LatLng(41.0082, 28.9784);

    return Scaffold(
      appBar: AppBar(title: const Text('Yürüyüş Rotası')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: _osmTileUrl,
                  userAgentPackageName: 'com.kaan.fitwalk',
                ),
                if (state.points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: state.points,
                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                if (state.points.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: state.points.last,
                        width: 24,
                        height: 24,
                        child: const Icon(Icons.my_location,
                            color: Colors.blue),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                    _Stat(
                        label: 'Mesafe',
                        value:
                            '${(state.distanceMeters / 1000).toStringAsFixed(2)} km'),
                    _Stat(label: 'Süre', value: _fmt(state.elapsed)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: state.isTracking
                      ? FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            final s = await controller.stop();
                            if (context.mounted && s != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Yürüyüş kaydedildi: ${(s.distanceMeters / 1000).toStringAsFixed(2)} km'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Bitir'),
                        )
                      : FilledButton.icon(
                          onPressed: () => controller.start(),
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
