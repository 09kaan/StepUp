import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import '../../models/walk_session.dart';

class WalkDetailScreen extends StatelessWidget {
  final WalkSession session;
  const WalkDetailScreen({super.key, required this.session});

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

  @override
  Widget build(BuildContext context) {
    final points =
        session.points.map((p) => LatLng(p.lat, p.lng)).toList();
    final hasRoute = points.length >= 2;
    final center = points.isNotEmpty
        ? points[points.length ~/ 2]
        : const LatLng(41.0082, 28.9784);

    return Scaffold(
      appBar: AppBar(title: const Text('Yürüyüş Detayı')),
      body: Column(
        children: [
          Expanded(
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
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route'),
                        points: points,
                        color: const Color(0xFF0E7C66),
                        width: 5,
                      ),
                    },
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
                        'Bu yürüyüş için kayıtlı rota yok.\nApple Maps geçişinden önceki yürüyüşlerde rota bilgisi bulunmayabilir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    label: 'Mesafe',
                    value:
                        '${(session.distanceMeters / 1000).toStringAsFixed(2)} km'),
                _Stat(
                    label: 'Süre',
                    value: '${(session.durationSeconds ~/ 60)} dk'),
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
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
