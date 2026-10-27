import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// How the daily reminder shows up. [alarm] rings loudly with the alarm
/// volume and shows on the lock screen; [notification] is a quiet notice.
enum ReminderMode {
  alarm('alarm'),
  notification('notification');

  const ReminderMode(this.storageValue);
  final String storageValue;

  static ReminderMode fromStorage(String? value) =>
      value == 'notification' ? ReminderMode.notification : ReminderMode.alarm;
}

/// Daily morning/evening reminders. Default timezone is Addis Ababa;
/// change the location if the app is distributed for another region.
class AzkarReminders {
  AzkarReminders._();
  static final AzkarReminders instance = AzkarReminders._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Android fixes a channel's sound and importance once it is created, so
  // the alarm and the quiet notice use two different channels.
  static const _alarmChannel = AndroidNotificationChannel(
    'azkar_alarm',
    'የአዝካር ማንቂያ',
    description: 'ጠዋትና ማታ አዝካር ለማስታወስ የሚጮህ ማንቂያ',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  static const _notifyChannel = AndroidNotificationChannel(
    'daily_azkar_reminders',
    'የአዝካር ማስታወሻ',
    description: 'የጠዋትና የማታ አዝካር ማስታወሻዎች',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Addis_Ababa'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    final androidPlugin = _android();
    await androidPlugin?.createNotificationChannel(_alarmChannel);
    await androidPlugin?.createNotificationChannel(_notifyChannel);
    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? _android() =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<bool?> requestPermission() async {
    await initialize();
    return _android()?.requestNotificationsPermission();
  }

  NotificationDetails _details(ReminderMode mode) {
    if (mode == ReminderMode.alarm) {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_alarm',
          'የአዝካር ማንቂያ',
          channelDescription: 'ጠዋትና ማታ አዝካር ለማስታወስ የሚጮህ ማንቂያ',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          autoCancel: true,
        ),
      );
    }
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_azkar_reminders',
        'የአዝካር ማስታወሻ',
        channelDescription: 'የጠዋትና የማታ አዝካር ማስታወሻዎች',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required ReminderMode mode,
  }) async {
    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));

    Future<void> schedule(AndroidScheduleMode scheduleMode) => _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          _details(mode),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

    // An alarm should ring on time. If exact alarms are not allowed on this
    // phone, fall back to a close-to-time schedule so the reminder still comes.
    if (mode == ReminderMode.alarm) {
      try {
        await schedule(AndroidScheduleMode.exactAllowWhileIdle);
        return;
      } catch (_) {
        // Fall through to the inexact schedule below.
      }
    }
    await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> configure({
    required bool enabled,
    required ReminderMode mode,
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    await initialize();
    await cancelAll();
    if (!enabled) return;
    await scheduleDaily(
      id: 1,
      hour: morningHour,
      minute: morningMinute,
      title: 'Daily Azkar ☀️',
      body: 'የጠዋት አዝካር ማለትዎን አይርሱ',
      mode: mode,
    );
    await scheduleDaily(
      id: 2,
      hour: eveningHour,
      minute: eveningMinute,
      title: 'Daily Azkar 🌙',
      body: 'የማታ አዝካር ማለትዎን አይርሱ',
      mode: mode,
    );
  }
}
