import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/challenge.dart';
import '../../models/challenge_template.dart';
import 'challenge_controller.dart';

String _unitLabel(ChallengeUnit u) {
  switch (u) {
    case ChallengeUnit.reps:
      return 'tekrar';
    case ChallengeUnit.steps:
      return 'adım';
    case ChallengeUnit.km:
      return 'km';
    case ChallengeUnit.minutes:
      return 'dk';
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

class EditChallengesScreen extends ConsumerStatefulWidget {
  const EditChallengesScreen({super.key});

  @override
  ConsumerState<EditChallengesScreen> createState() =>
      _EditChallengesScreenState();
}

class _EditChallengesScreenState
    extends ConsumerState<EditChallengesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(challengeTemplateRepoProvider).ensureDefaults(),
    );
  }

  Future<void> _edit(ChallengeTemplate? existing) async {
    final isNew = existing == null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final goalCtrl = TextEditingController(
        text: existing != null ? _num(existing.goalValue) : '');
    var unit = existing?.unit ?? ChallengeUnit.reps;
    var verification =
        existing?.verification ?? VerificationKind.manual;

    final okPressed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(isNew ? 'Yeni görev' : 'Görevi düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Görev adı'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Hedef değeri'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeUnit>(
                  value: unit,
                  decoration: const InputDecoration(labelText: 'Birim'),
                  items: ChallengeUnit.values
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text(_unitLabel(u))))
                      .toList(),
                  onChanged: (v) => setLocal(() => unit = v ?? unit),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VerificationKind>(
                  value: verification,
                  decoration: const InputDecoration(labelText: 'Onay türü'),
                  items: const [
                    DropdownMenuItem(
                      value: VerificationKind.manual,
                      child: Text('Elle onay'),
                    ),
                    DropdownMenuItem(
                      value: VerificationKind.auto,
                      child: Text('Otomatik (km mesafe)'),
                    ),
                  ],
                  onChanged: (v) =>
                      setLocal(() => verification = v ?? verification),
                ),
              ],
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
      ),
    );

    if (okPressed != true) return;

    final goal = double.tryParse(goalCtrl.text.replaceAll(',', '.')) ?? 0;
    if (titleCtrl.text.trim().isEmpty || goal <= 0) return;

    final t = existing ?? ChallengeTemplate();
    t.title = titleCtrl.text.trim();
    t.goalValue = goal;
    t.unit = unit;
    t.verification = verification;

    if (isNew) {
      t.sortOrder = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    await ref.read(challengeTemplateRepoProvider).save(t);
    ref.invalidate(challengeSuggestionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncTemplates = ref.watch(challengeTemplatesProvider);
    final suggestions =
        ref.watch(challengeSuggestionsProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevleri Düzenle'),
        actions: [
          IconButton(
            tooltip: 'Bugünü yenile',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(challengeRepoProvider).regenerateToday();
              ref.invalidate(todayChallengesProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bugünkü görevler şablonlardan yenilendi.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: const Text('Görev ekle'),
      ),
      body: asyncTemplates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('Henüz görev yok. Alttan ekle.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = list[i];
              final suggested = suggestions[t.id];

              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(challengeTemplateRepoProvider).delete(t.id);
                  ref.invalidate(challengeSuggestionsProvider);
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: Switch(
                        value: t.enabled,
                        onChanged: (v) => ref
                            .read(challengeTemplateRepoProvider)
                            .setEnabled(t.id, v),
                      ),
                      title: Text(t.title),
                      subtitle: Text(
                        '${_num(t.goalValue)} ${_unitLabel(t.unit)} • '
                        '${t.verification == VerificationKind.auto ? 'otomatik' : 'elle onay'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _edit(t),
                      ),
                    ),
                    if (suggested != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up,
                                size: 18, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  'Son 7 gün hep tamamladın — ${_num(suggested)} ${_unitLabel(t.unit)} yapalım mı?'),
                            ),
                            TextButton(
                              onPressed: () async {
                                t.goalValue = suggested;
                                await ref
                                    .read(challengeTemplateRepoProvider)
                                    .save(t);
                                ref.invalidate(challengeSuggestionsProvider);
                              },
                              child: const Text('Yükselt'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
