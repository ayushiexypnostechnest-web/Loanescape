import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EmiNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android & iOS initialization
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings ios = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    // Initialize the plugin
    await _notifications.initialize(settings);

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emi_channel', // id
      'EMI Reminder', // name
      description: 'EMI payment reminders',
      importance: Importance.max,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Schedule a notification 2 minutes from now
  static Future<void> scheduleTestEmiAfter2Minutes() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 2));

    await _notifications.zonedSchedule(
      999,
      'EMI Reminder',
      'This is a test EMI notification',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'emi_channel',
          'EMI Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // v19+ fix
    );
  }
}
