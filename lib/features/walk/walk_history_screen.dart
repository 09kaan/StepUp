import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../main.dart'; // isarProvider
import '../../models/walk_session.dart';
import '../../shared/widgets/app_card.dart';
import '../../theme/app_theme.dart';
import 'walk_detail_screen.dart';
import 'walk_tracking_controller.dart';

class WalkHistoryScreen extends ConsumerWidget {
  const WalkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(walkHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yürüyüş Geçmişi'),
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_walk,
                        size: 40,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Henüz yürüyüş kaydı yok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Yürüyüş sekmesinden rotanı kaydetmeye başlayabilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = list[index];
              return _WalkHistoryCard(session: s);
            },
          );
        },
      ),
    );
  }
}

class _WalkHistoryCard extends ConsumerWidget {
  final WalkSession session;
  const _WalkHistoryCard({required this.session});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}s ${m}dk';
    return '${m}dk';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = session;
    final km = (s.distanceMeters / 1000).toStringAsFixed(2);
    final dur = _formatDuration(s.durationSeconds);
    final dateStr = DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format(s.startTime);

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WalkDetailScreen(session: s),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Sol taraf: Vektörel Mini Rota Çizimi
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 68,
              height: 68,
              color: AppColors.bg,
              child: _MiniRouteThumbnail(points: s.points),
            ),
          ),
          const SizedBox(width: 14),
          // Orta alan: Başlık, Tarih ve Metrik Rozetleri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _MiniBadge(label: '$km km', icon: Icons.straighten),
                    _MiniBadge(label: dur, icon: Icons.timer),
                    if (s.paceFormatted != '-')
                      _MiniBadge(label: s.paceFormatted, icon: Icons.speed),
                    if (s.elevationGainMeters > 0)
                      _MiniBadge(
                        label: '${s.elevationGainMeters.toStringAsFixed(0)} m ↗',
                        icon: Icons.terrain,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Sağ: Silme menüsü veya Detay Oku
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDeleteWalk(context, ref, s);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Yürüyüşü Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.brand),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// GPS noktalarından normalize edilmiş hafif vektörel rota krokisi çizen widget.
class _MiniRouteThumbnail extends StatelessWidget {
  final List<RoutePoint> points;
  const _MiniRouteThumbnail({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const Center(
        child: Icon(
          Icons.directions_walk,
          size: 28,
          color: AppColors.brand,
        ),
      );
    }

    return CustomPaint(
      painter: _MiniRoutePainter(points),
      child: const SizedBox.expand(),
    );
  }
}

class _MiniRoutePainter extends CustomPainter {
  final List<RoutePoint> points;
  _MiniRoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = points.first.lat, maxLat = points.first.lat;
    double minLng = points.first.lng, maxLng = points.first.lng;

    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    final dLat = (maxLat - minLat).abs();
    final dLng = (maxLng - minLng).abs();

    const padding = 8.0;
    final drawW = size.width - (padding * 2);
    final drawH = size.height - (padding * 2);

    final maxDelta = dLat > dLng ? dLat : dLng;
    if (maxDelta == 0) return;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Haritada enlem yukarı doğru arttığı için Y ekseni terslenir
      final x = padding + ((p.lng - minLng) / maxDelta) * drawW;
      final y = size.height - padding - ((p.lat - minLat) / maxDelta) * drawH;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final routePaint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, routePaint);

    // Başlangıç noktası (Yeşil daire)
    final startX = padding + ((points.first.lng - minLng) / maxDelta) * drawW;
    final startY = size.height - padding - ((points.first.lat - minLat) / maxDelta) * drawH;
    final startPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(startX, startY), 3.5, startPaint);

    // Bitiş noktası (Kırmızı daire)
    final endX = padding + ((points.last.lng - minLng) / maxDelta) * drawW;
    final endY = size.height - padding - ((points.last.lat - minLat) / maxDelta) * drawH;
    final endPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(endX, endY), 3.5, endPaint);
  }

  @override
  bool shouldRepaint(_MiniRoutePainter old) => old.points != points;
}

Future<void> _confirmDeleteWalk(
  BuildContext context,
  WidgetRef ref,
  WalkSession session,
) async {
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
  await isar.writeTxn(() => isar.walkSessions.delete(session.id));

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yürüyüş silindi')),
    );
  }
}
