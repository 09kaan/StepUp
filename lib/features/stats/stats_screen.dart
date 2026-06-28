import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/stats_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';
import 'stats_controller.dart';

String _fmt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final async = _weekly
        ? ref.watch(weeklyStatsProvider)
        : ref.watch(monthlyStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weeklyStatsProvider);
          ref.invalidate(monthlyStatsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Hafta')),
                  ButtonSegment(value: false, label: Text('Ay')),
                ],
                selected: {_weekly},
                onSelectionChanged: (s) => setState(() => _weekly = s.first),
              ),
            ),
            const SizedBox(height: 20),
            async.when(
              loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Hata: $e'),
              data: (s) => Column(
                children: [
                  _SummaryGrid(summary: s),
                  const SizedBox(height: 20),
                  SectionHeader(
                      _weekly ? 'Son 7 gun' : 'Son 30 gun',
                      trailing: 'adim'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: SizedBox(
                      height: 200,
                      child: s.bestSteps == 0
                          ? const Center(
                              child: Text(
                                'Henuz veri yok.\nYurudukce grafigin dolacak.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : _BarChart(days: s.days, weekly: _weekly),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 10, color: AppColors.brand),
                      const SizedBox(width: 6),
                      const Text('Hedefe ulasilan gun',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 16),
                      Icon(Icons.circle,
                          size: 10,
                          color: AppColors.brandSoft.withValues(alpha: 0.55)),
                      const SizedBox(width: 6),
                      const Text('Diger gunler',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final StatsSummary summary;
  const _SummaryGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      _S('Toplam adim', _fmt(summary.totalSteps), Icons.directions_walk),
      _S('Gunluk ortalama', _fmt(summary.avgSteps), Icons.trending_up),
      _S('Toplam mesafe', '${summary.totalKm.toStringAsFixed(1)} km',
          Icons.straighten),
      _S('Hedefe ulasilan', '${summary.goalDays}/${summary.days.length} gun',
          Icons.flag),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: items.map((d) => _StatTile(data: d)).toList(),
    );
  }
}

class _S {
  final String label;
  final String value;
  final IconData icon;
  _S(this.label, this.value, this.icon);
}

class _StatTile extends StatelessWidget {
  final _S data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 20, color: AppColors.brand),
          const SizedBox(height: 8),
          Text(data.value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(data.label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<DayStat> days;
  final bool weekly;
  const _BarChart({required this.days, required this.weekly});

  @override
  Widget build(BuildContext context) {
    final maxSteps =
        days.fold<int>(0, (m, d) => d.steps > m ? d.steps : m);
    return CustomPaint(
      painter:
          _BarChartPainter(days: days, maxSteps: maxSteps, weekly: weekly),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<DayStat> days;
  final int maxSteps;
  final bool weekly;
  _BarChartPainter(
      {required this.days, required this.maxSteps, required this.weekly});

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    const labelHeight = 18.0;
    final chartHeight = size.height - labelHeight;
    final n = days.length;
    final slot = size.width / n;
    final barWidth = (slot * (weekly ? 0.5 : 0.7)).clamp(2.0, 28.0);
    final maxVal = maxSteps <= 0 ? 1 : maxSteps;

    final reachedPaint = Paint()..color = AppColors.brand;
    final normalPaint = Paint()
      ..color = AppColors.brandSoft.withValues(alpha: 0.55);

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final d = days[i];
      final h = (d.steps / maxVal) * (chartHeight - 6);
      final cx = slot * i + slot / 2;
      final left = cx - barWidth / 2;
      final top = chartHeight - h;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, h < 0 ? 0 : h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, d.goalReached ? reachedPaint : normalPaint);

      String? label;
      if (weekly) {
        const wd = ['Pt', 'Sa', 'Ca', 'Pe', 'Cu', 'Ct', 'Pz'];
        label = wd[(d.day.weekday - 1) % 7];
      } else if (i == 0 || i == n - 1 || d.day.day == 1 || i % 5 == 0) {
        label = '${d.day.day}';
      }
      if (label != null) {
        tp.text = TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        );
        tp.layout();
        tp.paint(
            canvas, Offset(cx - tp.width / 2, size.height - labelHeight + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.days != days ||
      old.maxSteps != maxSteps ||
      old.weekly != weekly;
}
