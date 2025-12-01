import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class NotificationService {
  
  static Future<void> cancelNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
    } catch (e) {
      print("Error cancelling notification: $e");
    }
  }

  static Future<void> scheduleNotification(
      int id, String title, String body, DateTime dateTime) async {

    if (!dateTime.isAfter(DateTime.now())) return;

    // Convert to TZ time
    final scheduleTime = tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Channel for task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final tz.TZDateTime scheduled = tz.TZDateTime.from(dateTime, tz.local);


    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled, // tz.TZDateTime instance
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // one-time notification
    );

 }
}
