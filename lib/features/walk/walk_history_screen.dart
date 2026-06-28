import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'walk_tracking_controller.dart';
import 'walk_detail_screen.dart';

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
            return const Center(child: Text('Henüz yürüyüş kaydı yok.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final s = list[index];
              final km = (s.distanceMeters / 1000).toStringAsFixed(2);
              final min = (s.durationSeconds / 60).toStringAsFixed(1);
              final date = '${s.startTime.day.toString().padLeft(2, '0')}/${s.startTime.month.toString().padLeft(2, '0')}/${s.startTime.year} ${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')}';

              return ListTile(
                leading: const Icon(Icons.directions_walk),
                title: Text('$km km - $min dk'),
                subtitle: Text(date),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WalkDetailScreen(session: s),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
