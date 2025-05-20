import 'dart:convert';
import 'package:Appointly/module/notification/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Appointly/main.dart' show flutterLocalNotificationsPlugin;
import 'package:logger/logger.dart';

class NotificationHelper {
  static final Logger _logger = Logger();
  static Future<void> showBookingNotification({
    required BuildContext context,
    required String serviceName,
    required String date,
    required String time,
    required String option,
    required String userId,
    required int bookingId,
  }) async {
    print('🔔 NotificationHelper: Creating notification');
    print('📝 Details: userId=$userId, bookingId=$bookingId');
    print(
        '📝 Service: $serviceName, Date: $date, Time: $time, Option: $option');
    _logger.d('Creating notification for booking $bookingId, user $userId');

    final title = 'Booking Confirmed!';
    final body =
        'Your appointment for $serviceName has been scheduled for $date at $time ($option)';

    // Buat payload dengan bookingId sebagai integer
    final payload = jsonEncode({
      'bookingId': bookingId, // Pastikan bookingId adalah integer
      'type': 'booking',
    });

    _logger.d('Notification payload: $payload');

    try {
      // Tampilkan notifikasi lokal
      await flutterLocalNotificationsPlugin.show(
        bookingId, // Gunakan bookingId sebagai notification ID
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'appointly_channel',
            'Appointly Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: payload,
      ); // Tambahkan notifikasi ke bloc
      if (context.mounted) {
        print('🔄 Adding notification to NotificationBloc');
        print(
            '📝 Notification: title=$title, userId=$userId, bookingId=$bookingId');
        BlocProvider.of<NotificationBloc>(context, listen: false).add(
          AddNotification(
            title: title,
            body: body,
            status: 'confirmed',
            time: DateTime.now().toString(),
            userId: userId,
            bookingId: bookingId,
          ),
        );
        print('✅ Notification successfully added to bloc');
      }
    } catch (e) {
      _logger.e('Error showing notification: $e');
    }
  }
}
