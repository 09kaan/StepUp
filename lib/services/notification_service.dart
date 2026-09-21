import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/daily_activity.dart';
import '../models/walk_session.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 1001;

  static const String reminderTitle = 'Bugün henüz yürümedin! 👟';
  static const String reminderBody =
      'Günü hareketsiz kapatma, serini korumak için kısa bir yürüyüşe çık!';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  /// iOS/Android 13+ bildirim izni ister.
  Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await android?.requestNotificationsPermission();

    return iosGranted ?? androidGranted ?? true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Günlük Hatırlatma',
          channelDescription: 'Yürüyüş ve seri hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Her gün aynı saatte tekrarlayan hatırlatma.
  /// [forceTomorrow] true ise, bugün yürüyüş yapıldığı için bugünkü 19:00 atlanır ve yarına kurulur.
  Future<void> scheduleDailyReminder({
    int hour = 19,
    int minute = 0,
    bool forceTomorrow = false,
  }) async {
    await _plugin.zonedSchedule(
      dailyReminderId,
      reminderTitle,
      reminderBody,
      _nextInstanceOf(hour, minute, forceTomorrow: forceTomorrow),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // her gün aynı saat
    );
  }

  /// Kullanıcının bugün yürüyüş yapıp yapmadığını kontrol eder:
  /// - Bugün yürüyüş tamamlandıysa veya günlük hedef sağlandıysa:
  ///   Bugünkü 19:00 bildirimini atlar, hatırlatıcıyı yarına erteler.
  /// - Henüz yapılmadıysa:
  ///   Bugün saat 19:00'da (saat henüz geçmediyse) hatırlatacak şekilde kurar.
  Future<void> syncReminderWithTodayActivity(
    Isar isar, {
    int hour = 19,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    // 1. Bugün tamamlanmış bir yürüyüş seansı var mı?
    final hasWalkToday = await isar.walkSessions
            .filter()
            .isActiveEqualTo(false)
            .startTimeBetween(startOfToday, endOfToday)
            .findFirst() !=
        null;

    // 2. Günlük adım hedefi tamamlanmış mı?
    final dailyActivity = await isar.dailyActivitys
        .filter()
        .dateEqualTo(startOfToday)
        .findFirst();
    final hasReachedGoal = dailyActivity?.goalReached ?? false;

    final completedToday = hasWalkToday || hasReachedGoal;

    await cancelDailyReminder();
    await scheduleDailyReminder(
      hour: hour,
      minute: minute,
      forceTomorrow: completedToday,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(dailyReminderId);

  /// Hemen test bildirimi (butona bas, doğru çalışıyor mu gör).
  Future<void> showTestNow() async {
    await _plugin.show(
      2002,
      reminderTitle,
      reminderBody,
      _details,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute, {bool forceTomorrow = false}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (forceTomorrow || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
