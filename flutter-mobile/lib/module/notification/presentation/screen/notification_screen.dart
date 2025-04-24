import 'dart:math';

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/widget/empty_state.dart';
import 'package:Appointly/module/notification/presentation/bloc/notification_bloc.dart';
import 'package:Appointly/module/notification/presentation/widget/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:Appointly/main.dart' show flutterLocalNotificationsPlugin;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Logger _logger = Logger();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<Map<String, dynamic>> get notifications =>
      context.read<NotificationBloc>().state.notifications;

  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    _logger.d('FCM Token: $token');

    // foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      _logger.d('Message: $title, $body');

      _showNotification(title, body);

      context.read<NotificationBloc>().add(AddNotification(
            title: title,
            body: body,
            status: 'pending',
            time: DateTime.now().toString(),
            userId: widget.userId,
          ));
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

    context.read<NotificationBloc>().add(AddNotification(
          title: title,
          body: body,
          status: 'pending',
          time: DateTime.now().toString(),
          userId: widget.userId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
      if (state is NotificationLoading) {
        return Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: NotificationItem(
                  title: 'Loading...',
                  timeStamp: 'Loading...',
                  indicatorStatus: 'Loading...',
                  onTap: () {},
                ),
              );
            },
          ),
        );
      } else if (state is NotificationError) {
        return Center(
          child: Text('Error: ${state.message}'),
        );
      } else if (state is NotificationLoaded) {
        _logger.d('NotificationState: ${state.runtimeType}');
        _logger.d('All notifications: ${state.notifications.length}');

        final filteredNotifications = state.notifications
            .where((notif) => notif['userId'] == widget.userId)
            .toList();

        return Scaffold(
          backgroundColor: ColorPallete.backgroundBody,
          appBar: _buildAppBar(),
          body: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: filteredNotifications.isEmpty
                ? Center(
                    child: EmptyState(),
                  )
                : ListView.builder(
                    cacheExtent: 500.0,
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
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
      return Center(
        child: EmptyState(),
      );
    });
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
