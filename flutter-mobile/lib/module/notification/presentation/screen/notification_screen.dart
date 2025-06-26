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
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isInitialLoad = true;
  bool _isRefreshing = false;
  String? _lastCheck;

  @override
  void initState() {
    super.initState();
    print('🚀 Initializing NotificationScreen');
    print('👤 User ID: ${widget.userId}');
    print('📦 Booking ID: ${widget.bookingId}');

    _initFirebaseMessaging();
    _loadNotifications();

    // Set up a periodic refresh (every minute)
    _setupPeriodicRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupPeriodicRefresh() {
    // Load last check time
    _loadLastCheckTime();

    // Set up timer for periodic polling
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _refreshNotifications();
        _setupPeriodicRefresh();
      }
    });
  }

  Future<void> _loadLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastCheck = prefs.getString('notifications_last_check_${widget.userId}');
      print('🕒 Last check time loaded: $_lastCheck');
    });
  }

  void _loadNotifications() {
    _logger.d('Loading notifications for user: ${widget.userId}');

    if (_isInitialLoad) {
      // On initial load, get stored notifications first
      context.read<NotificationBloc>().add(
            GetNotifications(userId: widget.userId),
          );

      // Then fetch from API
      _fetchFromApi();
      _isInitialLoad = false;
    } else {
      // On subsequent loads, just fetch from API
      _fetchFromApi();
    }
  }

  void _fetchFromApi() {
    _logger.d('Fetching notifications from API');
    context.read<NotificationBloc>().add(
          FetchNotificationsFromApi(
            userId: widget.userId,
            lastCheck: _lastCheck,
          ),
        );
  }

  Future<void> _refreshNotifications() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _fetchFromApi();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
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
        _refreshNotifications();
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
    print('📝 Booking ID: $bookingId');

    // Persiapkan detail notifikasi
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'appointly_notifications', // channel id
      'Appointly Notifications', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      bookingId > 0 ? bookingId : DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: bookingId > 0 ? bookingId.toString() : '0',
    );

    // Tambahkan notifikasi ke state lokal (widget)
    if (mounted) {
      _logger.d('Adding notification to local state');
      context.read<NotificationBloc>().add(
            AddNotification(
              title: title,
              body: body,
              status: '', // Status could be determined based on title/body
              time: DateTime.now().toIso8601String(),
              userId: widget.userId,
              bookingId: bookingId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              // Show clear button only if there are notifications
              if (state is NotificationLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                          ClearNotifications(userId: widget.userId),
                        );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading && _isInitialLoad) {
              return _buildLoadingState();
            } else if (state is NotificationError) {
              return _buildErrorState(state.message);
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const EmptyState();
              }
              return _buildNotificationList(state.notifications);
            }
            return _buildNotificationList(state.notifications);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const NotificationItem(
            title: 'Loading notification...',
            timeStamp: '2023-01-01 00:00:00',
            indicatorStatus: 'pending',
            onTap: null,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPallete.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _loadNotifications,
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final int bookingId = notification['bookingId'] is int
            ? notification['bookingId']
            : int.tryParse('${notification['bookingId']}') ?? 0;
        String status =
            notification['status']?.toString().toLowerCase() ?? 'pending';

        // Ensure status matches one of our expected values
        if (!['approved', 'completed', 'declined', 'pending']
            .contains(status)) {
          // Default mapping based on title if available
          if ((notification['title'] ?? '')
              .toLowerCase()
              .contains('approved')) {
            status = 'approved';
          } else if ((notification['title'] ?? '')
              .toLowerCase()
              .contains('completed')) {
            status = 'completed';
          } else if ((notification['title'] ?? '')
              .toLowerCase()
              .contains('declined')) {
            status = 'declined';
          }
        }

        return NotificationItem(
          title: notification['title'] ?? '',
          timeStamp: notification['time'] ?? '',
          indicatorStatus: status,
          onTap: bookingId > 0
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMeetingSuccess(
                        bookingId: bookingId,
                      ),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}
