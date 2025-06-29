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
  DateTime? _lastApiCall;
  static const Duration _apiCooldown =
      Duration(seconds: 30); // Prevent API calls within 30 seconds
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

    // Force a delayed refresh to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('🔄 Delayed force refresh...');
        _forceRefreshUI();
      }
    });
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
      // On subsequent loads, reload stored notifications first to get updated data
      context.read<NotificationBloc>().add(
            GetNotifications(userId: widget.userId),
          );
      // Then fetch from API
      _fetchFromApi();
    }
  }

  void _fetchFromApi() {
    // Check if we're within the cooldown period
    if (_lastApiCall != null &&
        DateTime.now().difference(_lastApiCall!) < _apiCooldown) {
      print('⏰ API call within cooldown period, skipping...');
      return;
    }

    _logger.d('Fetching notifications from API');
    _lastApiCall = DateTime.now();

    context.read<NotificationBloc>().add(
          FetchNotificationsFromApi(
            userId: widget.userId,
            lastCheck: _lastCheck,
            context: context,
          ),
        );
  }

  Future<void> _refreshNotifications() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Force reload from SharedPreferences first to show updated data
      context.read<NotificationBloc>().add(
            GetNotifications(userId: widget.userId),
          );

      await Future.delayed(const Duration(milliseconds: 300));
      _fetchFromApi();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // Method to force UI update and reload all notifications
  void _forceRefreshUI() {
    print('🔄 Force refreshing UI...');
    setState(() {
      _isInitialLoad = true;
    });
    _loadNotifications();
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
          // Add refresh button
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: _forceRefreshUI,
          ),
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
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            // Listen to state changes and force UI update
            if (state is NotificationLoaded) {
              print(
                  '🔄 UI: NotificationLoaded state detected with ${state.notifications.length} notifications');
              // Force UI rebuild
              if (mounted) {
                setState(() {});
              }
            }
          },
          builder: (context, state) {
            print('🔍 UI: Building with state: ${state.runtimeType}');

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
            body: 'Loading appointment details...',
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
    print(
        '🔍 UI: Building notification list with ${notifications.length} items');

    return ListView.builder(
      key: ValueKey(
          'notification_list_${notifications.length}_${DateTime.now().millisecondsSinceEpoch}'),
      padding: const EdgeInsets.only(
        top: 10,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        print(
            '🔍 NotificationScreen: Processing notification $index: ${notification['title']} - ${notification['body']}');

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

        print(
            '🔍 NotificationScreen: Creating NotificationItem with body: ${notification['body']}');
        return NotificationItem(
          key: ValueKey(
              'notification_${notification['id'] ?? index}_${notification['time']}'),
          title: notification['title'] ?? '',
          timeStamp: notification['time'] ?? '',
          body: _formatNotificationDescription(
              notification), // Use formatted description
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

  // Helper method to format notification description with service information
  String _formatNotificationDescription(Map<String, dynamic> notification) {
    final title = notification['title']?.toString() ?? '';
    final body = notification['body']?.toString() ?? '';
    final serviceName = notification['serviceName']?.toString() ?? '';
    final bookingDate = notification['bookingDate']?.toString() ?? '';
    final bookingTime = notification['bookingTime']?.toString() ?? '';
    final location = notification['location']?.toString() ?? '';

    print(
        '🔍 Formatting description: title=$title, serviceName=$serviceName, date=$bookingDate, time=$bookingTime, location=$location');

    // If we already have a well-formatted body from API, enhance it with service info
    if (body.isNotEmpty && !body.contains('T') && body.length > 20) {
      String enhancedBody = body;

      // Add service information if not already included
      if (serviceName.isNotEmpty &&
          serviceName != 'null' &&
          serviceName != 'undefined') {
        if (!body.toLowerCase().contains(serviceName.toLowerCase())) {
          enhancedBody += '\n📋 Service: $serviceName';
        }
      }

      // Add date and time if not already included
      if (bookingDate.isNotEmpty &&
          bookingDate != 'null' &&
          bookingDate != 'undefined' &&
          bookingTime.isNotEmpty &&
          bookingTime != 'null' &&
          bookingTime != 'undefined') {
        if (!body.toLowerCase().contains(bookingDate.toLowerCase())) {
          String formattedTime = _formatTime(bookingTime);
          enhancedBody += '\n📅 ${_formatDate(bookingDate)} at $formattedTime';
        }
      }

      // Add location info for online meetings
      if (location.isNotEmpty &&
          location != 'null' &&
          location != 'undefined') {
        if (location.startsWith('https://')) {
          if (!body.toLowerCase().contains('online')) {
            enhancedBody += '\n🔗 Online Meeting';
          }
        } else if (!body.toLowerCase().contains('location')) {
          enhancedBody += '\n📍 Location: $location';
        }
      }

      return enhancedBody;
    }

    // Build comprehensive description from scratch
    String description = '';

    // Determine status message
    if (title.toLowerCase().contains('confirmed')) {
      description = 'Your booking has been confirmed ✅';
    } else if (title.toLowerCase().contains('approved')) {
      description = 'Your appointment has been approved ✅';
    } else if (title.toLowerCase().contains('declined')) {
      description = 'Your appointment has been declined ❌';
    } else if (title.toLowerCase().contains('pending')) {
      description = 'Your appointment is pending approval ⏳';
    } else {
      description = 'Booking status updated';
    }

    // Always add service information if available
    if (serviceName.isNotEmpty &&
        serviceName != 'null' &&
        serviceName != 'undefined') {
      description += '\n📋 Service: $serviceName';
    }

    // Add date and time information
    if (bookingDate.isNotEmpty &&
        bookingDate != 'null' &&
        bookingDate != 'undefined' &&
        bookingTime.isNotEmpty &&
        bookingTime != 'null' &&
        bookingTime != 'undefined') {
      String formattedTime = _formatTime(bookingTime);
      String formattedDate = _formatDate(bookingDate);
      description += '\n📅 $formattedDate at $formattedTime';
    }

    // Add location information
    if (location.isNotEmpty && location != 'null' && location != 'undefined') {
      if (location.startsWith('https://')) {
        description += '\n🔗 Online Meeting';
      } else {
        description += '\n📍 Location: $location';
      }
    }

    print('🔍 Final formatted description: $description');
    return description;
  }

  // Helper method to format time
  String _formatTime(String time) {
    try {
      if (time.contains(':')) {
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = timeParts[1];
          if (hour > 12) {
            return '${hour - 12}:$minute PM';
          } else if (hour == 12) {
            return '12:$minute PM';
          } else if (hour == 0) {
            return '12:$minute AM';
          } else {
            return '$hour:$minute AM';
          }
        }
      }
    } catch (e) {
      print('⚠️ Error formatting time: $e');
    }
    return time;
  }

  // Helper method to format date
  String _formatDate(String date) {
    try {
      if (date.contains('-')) {
        final dateParts = date.split('-');
        if (dateParts.length >= 3) {
          final year = dateParts[0];
          final month = dateParts[1];
          final day = dateParts[2];

          // Convert month number to name
          final monthNames = [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          final monthName = monthNames[int.parse(month)];

          return '$day $monthName $year';
        }
      }
    } catch (e) {
      print('⚠️ Error formatting date: $e');
    }
    return date;
  }
}
