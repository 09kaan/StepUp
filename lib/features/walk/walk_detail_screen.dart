import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../main.dart'; // isarProvider
import '../../models/walk_session.dart';
import '../../theme/app_theme.dart';

class WalkDetailScreen extends ConsumerStatefulWidget {
  final WalkSession session;
  const WalkDetailScreen({super.key, required this.session});

  @override
  ConsumerState<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends ConsumerState<WalkDetailScreen> {
  late WalkSession _session;

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

  Future<void> _editTitle() async {
    final ctrl = TextEditingController(text: _session.title ?? _session.displayTitle);
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
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: _confirmDelete,
          ),
        ],
      ),
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
                        color: AppColors.brand,
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
                        'Bu yürüyüş için kayıtlı rota koordinatı yok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Mesafe',
                        value: '${(_session.distanceMeters / 1000).toStringAsFixed(2)} km',
                        icon: Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        label: 'Süre',
                        value: _formatDuration(_session.durationSeconds),
                        icon: Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        label: 'Ort. Tempo',
                        value: _session.paceFormatted,
                        icon: Icons.speed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Tırmanış',
                        value: '${_session.elevationGainMeters.toStringAsFixed(0)} m',
                        icon: Icons.terrain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        label: 'Çıkış Eğimi',
                        value: '%${_session.avgGradePercent.toStringAsFixed(1)}',
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        label: 'Kalori',
                        value: '${_session.caloriesEstimated.toStringAsFixed(0)} kcal',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
