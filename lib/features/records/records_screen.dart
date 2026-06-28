import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';
import 'records_controller.dart';

String _fmt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

String _dur(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return h > 0 ? '${h}s ${m}dk' : '${m}dk';
}

String _date(DateTime? d) {
  if (d == null) return '-';
  const months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];
  return '${d.day} ${months[d.month]} ${d.year}';
}

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kişisel Rekorlar')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(recordsProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Padding(
                  padding: const EdgeInsets.all(24), child: Text('Hata: $e')),
            ],
          ),
          data: (r) {
            final hasData = r.bestDaySteps > 0 || r.longestWalkKm > 0;
            if (!hasData) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'Henüz rekor yok.\nYürüdükçe rekorların burada birikecek.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              );
            }
            final items = <_Rec>[
              _Rec(Icons.local_fire_department, 'En uzun seri',
                  '${r.longestStreak} gün', 'Üst üste hedef tutturma'),
              _Rec(Icons.directions_walk, 'En çok adım (gün)',
                  _fmt(r.bestDaySteps), _date(r.bestDayDate)),
              _Rec(Icons.route, 'En uzun yürüyüş',
                  '${r.longestWalkKm.toStringAsFixed(2)} km',
                  _date(r.longestWalkDate)),
              _Rec(Icons.timer, 'En uzun süre', _dur(r.longestWalkSeconds),
                  _date(r.longestWalkDate)),
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const SectionHeader('Tüm zamanlar'),
                const SizedBox(height: 8),
                ...items.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecordCard(rec: e),
                  ),
                ),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Mini('Toplam adım', _fmt(r.totalSteps)),
                      _Mini('Toplam mesafe',
                          '${r.totalKm.toStringAsFixed(1)} km'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Rec {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  _Rec(this.icon, this.title, this.value, this.subtitle);
}

class _RecordCard extends StatelessWidget {
  final _Rec rec;
  const _RecordCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(rec.icon, color: AppColors.brand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(rec.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(rec.value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  const _Mini(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
