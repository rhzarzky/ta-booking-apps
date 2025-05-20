import 'dart:convert';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/notification/presentation/widget/empt_state.dart';
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
  final int bookingId;

  const NotificationScreen({
    super.key,
    required this.userId,
    this.bookingId = 0,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Logger _logger = Logger();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    print('🚀 Initializing NotificationScreen');
    print('👤 User ID: ${widget.userId}');
    print('📦 Booking ID: ${widget.bookingId}');
    
    _initFirebaseMessaging();
    _loadNotifications();
  }

  void _loadNotifications() {
    _logger.d('Memuat notifikasi untuk user: ${widget.userId}');
    context.read<NotificationBloc>().add(
          GetNotifications(userId: widget.userId),
        );
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

      // Extract bookingId dari data payload jika ada
      final bookingId =
          int.tryParse('${message.data['bookingId'] ?? '0'}') ?? 0;

      _showNotification(title, body, bookingId);

      // Refresh notifikasi setelah menerima pesan baru
      if (mounted) {
        context.read<NotificationBloc>().add(
              GetNotifications(userId: widget.userId),
            );
      }
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (mounted) {
        final bookingId =
            int.tryParse('${message.data['bookingId'] ?? '0'}') ?? 0;
        if (bookingId > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMeetingSuccess(
                bookingId: bookingId,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> _showNotification(
      String title, String body, int bookingId) async {
    print('🔔 Showing local notification');
    print('📝 Title: $title');
    print('📝 Body: $body');
    print('📝 BookingId: $bookingId');
    
    final payload = jsonEncode({
      'bookingId': bookingId,
      'type': 'booking',
    });

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointly_channel',
      'Appointly Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      bookingId, // Gunakan bookingId sebagai notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    if (mounted) {
      context.read<NotificationBloc>().add(AddNotification(
            title: title,
            body: body,
            status: 'pending',
            time: DateTime.now().toString(),
            userId: widget.userId,
            bookingId: bookingId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          _logger.d(
              'NotificationState: ${state.runtimeType}, userId: ${widget.userId}');
          _logger
              .d('Current notifications count: ${state.notifications.length}');

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.primaryColor,
                    ),
                    child: Text('Coba Lagi',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          } else {
            final filteredNotifications = state.notifications
                .where((notif) => notif['userId'] == widget.userId)
                .toList();

            _logger
                .d('Filtered notifications: ${filteredNotifications.length}');

            if (filteredNotifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmptyState(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallete.primaryColor,
                      ),
                      child: Text('Refresh',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh data notifikasi
                _logger.d('Refreshing notifications for user ${widget.userId}');
                context.read<NotificationBloc>().add(
                      GetNotifications(userId: widget.userId),
                    );
              },
              child: ListView.builder(
                cacheExtent: 500.0,
                padding: EdgeInsets.only(
                  bottom: 8.0,
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final item = filteredNotifications[index];

                  // Gunakan bookingId dari notifikasi, atau default 0 jika tidak ada
                  final int notifBookingId = item['bookingId'] != null
                      ? (item['bookingId'] is int
                          ? item['bookingId']
                          : int.tryParse('${item['bookingId']}') ?? 0)
                      : 0;

                  _logger.d(
                      'Item $index: title=${item['title']}, bookingId=$notifBookingId');

                  return NotificationItem(
                    title: item['title'] ?? '',
                    indicatorStatus: item['status'] ?? 'pending',
                    timeStamp: item['time'] ?? '',
                    onTap: () {
                      // Gunakan ID dari notifikasi, bukan dari widget global
                      if (notifBookingId > 0) {
                        _logger.d(
                            'Opening booking detail with ID: $notifBookingId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMeetingSuccess(
                              bookingId: notifBookingId,
                            ),
                          ),
                        );
                      } else {
                        // Tampilkan pesan error jika tidak ada booking ID yang valid
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detail pemesanan tidak tersedia'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          }
        },
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
