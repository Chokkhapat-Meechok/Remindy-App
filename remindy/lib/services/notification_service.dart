import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../models/reminder.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Only initialize notification plugins on supported platforms.
    // Some plugins used here (timezone / native timezone) may not provide
    // implementations on Windows or Web in this project setup and can throw
    // MissingPluginException during startup. To keep the app stable across
    // platforms we skip plugin initialization where it's not supported and
    // make scheduling a no-op on those platforms.
    final supportsPlatform =
        !kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isLinux);
    if (!supportsPlatform) {
      _initialized = true; // mark initialized but do not touch native plugins
      return;
    }

    tzdata.initializeTimeZones();
    try {
      final String localTz = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      if (kDebugMode) print('Could not get local timezone: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  int _notificationIdFor(String id) => id.hashCode & 0x7fffffff;

  Future<void> scheduleReminder(Reminder r) async {
    if (r.dueAt == null) return;
    if (r.isDeleted || r.isCompleted) return;
    // Avoid scheduling on unsupported platforms (no-op)
    final supportsPlatform =
        !kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isLinux);
    if (!supportsPlatform) return;
    if (!_initialized) await init();

    final scheduled = tz.TZDateTime.from(r.dueAt!, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'remindy_channel',
      'Remindy reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notificationIdFor(r.id),
      r.title.isEmpty ? 'Reminder' : r.title,
      r.description.isEmpty ? null : r.description,
      scheduled,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelReminder(String id) async {
    final supportsPlatform =
        !kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isLinux);
    if (!supportsPlatform) return;
    if (!_initialized) await init();
    final nid = _notificationIdFor(id);
    await _plugin.cancel(nid);
  }

  Future<void> cancelAll() async {
    final supportsPlatform =
        !kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isLinux);
    if (!supportsPlatform) return;
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
