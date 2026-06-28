import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 1001;

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
    await _plugin.initialize(settings: settings);
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
  Future<void> scheduleDailyReminder({int hour = 19, int minute = 0}) async {
    await _plugin.zonedSchedule(
      id: dailyReminderId,
      title: 'Bugün yürüdün mü? 🚶',
      body: 'Serini koru ve günlük hedefini tamamla!',
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // her gün aynı saat
    );
  }

  /// Hemen test bildirimi (butona bas, doğru çalışıyor mu gör).
  Future<void> showTestNow() async {
    await _plugin.show(
      id: 2002,
      title: 'Test bildirimi 🔔',
      body: 'Bildirimler çalışıyor!',
      notificationDetails: _details,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
