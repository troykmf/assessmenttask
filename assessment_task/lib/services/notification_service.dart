import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:assessment_task/models/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;
  NotificationService._internal();

  static Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _instance._notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {}, // Add notification tap handler
    );
  }

  Future<void> scheduleReminder(Contact contact) async {
    // Use zonedSchedule instead of show
    await _notifications.zonedSchedule(
      contact.hashCode,
      'Call Reminder',
      'Reminder: Call ${contact.name} at ${contact.phoneNumber}',
      // Schedule for 1 minute from now
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'call_reminders',
          'Call Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   static Future<void> init() async {
//     const AndroidInitializationSettings android = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const DarwinInitializationSettings ios = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     await _instance._notifications.initialize(
//       const InitializationSettings(android: android, iOS: ios),
//     );
//   }

//   Future<void> scheduleReminder(Contact contact) async {
//     const AndroidNotificationDetails android = AndroidNotificationDetails(
//       'call_reminders',
//       'Call Reminders',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const DarwinNotificationDetails ios = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     await _notifications.show(
//       contact.hashCode,
//       'Call Reminder',
//       'Reminder: Call ${contact.name} at ${contact.phoneNumber}',
//       const NotificationDetails(android: android, iOS: ios),
//     );
//   }
// }

final notificationServiceProvider = Provider((ref) => NotificationService());
