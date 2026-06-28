import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'services/notification_service.dart';
import 'app.dart';
import 'models/challenge.dart';
import 'models/daily_activity.dart';
import 'models/walk_session.dart';

/// Isar'a her yerden Riverpod ile erişacağız.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider main() içinde override edilmeli');
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [DailyActivitySchema, WalkSessionSchema, ChallengeSchema],
    directory: dir.path,
  );

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await NotificationService.instance.scheduleDailyReminder(hour: 19, minute: 0);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const FitWalkApp(),
    ),
  );
}
