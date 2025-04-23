import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Appointly/main.dart' show flutterLocalNotificationsPlugin;
import 'package:Appointly/module/notification/presentation/screen/notification_screen.dart';

class NotificationHelper {
  static Future<void> showBookingNotification({
    required BuildContext context,
    required String serviceName,
    required String date,
    required String time,
    required String option,
  }) async {
    final title = 'Booking Confirmed!';
    final body =
        'Your appointment for $serviceName has been scheduled for $date at $time ($option)';

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointly_channel',
          'Appointly Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          
        ),
      ),
    );

    // Tambahkan notifikasi ke NotificationScreen state
    NotificationScreen.addNotification(
      title: title,
      body: body,
      status: 'confirmed',
      time: DateTime.now().toString(),
    );
  }
}
