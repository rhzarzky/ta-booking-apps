import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/notification/presentation/widget/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:Appointly/main.dart' show flutterLocalNotificationsPlugin;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  // Static variable untuk menyimpan notifikasi
  static List<Map<String, dynamic>> _notifications = [];

  // Static method untuk menambah notifikasi
  static void addNotification({
    required String title,
    required String body,
    required String status,
    required String time,
  }) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'status': status,
      'time': time,
    });
  }

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Logger _logger = Logger();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<Map<String, dynamic>> get notifications =>
      NotificationScreen._notifications;

  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    _logger.d('FCM Token: $token');

    // foregraound message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      _logger.d('Message: $title, $body');

      _showNotification(title, body);

      setState(() {
        NotificationScreen.addNotification(
          title: title,
          body: body,
          status: 'pending',
          time: DateTime.now().toString(),
        );
      });
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointly_channel',
      'Appointly Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
    );

    setState(() {
      NotificationScreen.addNotification(
        title: title,
        body: body,
        status: 'pending',
        time: DateTime.now().toString(),
      );
    });
  }

  // Static method to be called from other screens
  static Future<void> showBookingNotification(
    BuildContext context, {
    required String serviceName,
    required String date,
    required String time,
    required String option,
  }) async {
    final title = 'Booking Confirmed!';
    final body =
        'Your appointment for $serviceName has been scheduled for $date at $time ($option)';

    // Get the instance of NotificationScreen's state
    final state = context.findAncestorStateOfType<_NotificationScreenState>();
    if (state != null) {
      await state._showNotification(title, body);
    } else {
      // If state is not found, show notification directly
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  'No notifications yet',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    color: ColorPallete.darkBlack,
                  ),
                ),
              )
            : ListView.builder(
                cacheExtent: 500.0,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return NotificationItem(
                    title: item['title'] ?? '',
                    indicatorStatus: item['status'] ?? 'pending',
                    timeStamp: item['time'] ?? '',
                    onTap: () {},
                  );
                },
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0.0,
      title: Text(
        'Your Notifications',
        style: GoogleFonts.sourceSans3(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPallete.darkBlack,
        ),
      ),
    );
  }
}
