import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assessment_task/models/contact.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      await _createNotificationChannel();
      await _requestExactAlarmPermission();
    }
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_reminders',
      'Call Reminders',
      description: 'Channel for call reminders',
      importance: Importance.max,

      playSound: true,
      enableVibration: true,
    );

    await _instance._notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestExactAlarmPermission() async {
    try {
      final androidPlugin =
          _instance._notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Exact alarm permission error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+, request POST_NOTIFICATIONS
      if (await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false) {
        return true;
      }

      final bool? result =
          await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();

      return result ?? false;
    } else if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> scheduleReminder(Contact contact) async {
    try {
      const AndroidNotificationDetails android = AndroidNotificationDetails(
        'call_reminders',
        'Call Reminders',
        channelDescription: 'Scheduled reminders for important calls',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      );

      const DarwinNotificationDetails ios = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _notifications.zonedSchedule(
        contact.hashCode,
        'Call Reminder',
        'Reminder: Call ${contact.name} at ${contact.phoneNumber}',
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
        const NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'contact_reminder',
      );
    } on PlatformException catch (e) {
      debugPrint('Notification error: ${e.message}');
      rethrow;
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
