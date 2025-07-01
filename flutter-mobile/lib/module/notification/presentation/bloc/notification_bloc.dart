import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Appointly/main.dart' show flutterLocalNotificationsPlugin;

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final Logger _logger = Logger();
  final AuthRepository _authRepository = AuthRepository();

  // Add flags to prevent duplicate API calls
  bool _isFetchingFromApi = false;
  Set<String> _processedNotificationIds = <String>{};

  NotificationBloc() : super(NotificationInitial()) {
    print('🏃 Initializing NotificationBloc');

    // Migrate old notifications on init
    _migrateNotifications();

    on<AddNotification>((event, emit) async {
      print('📥 Adding new notification: ${event.title}');
      emit(NotificationLoading());
      try {
        // Get current notifications for this specific user from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String notificationKey = 'notifications_${event.userId}';
        final String? existingData = prefs.getString(notificationKey);
        List<Map<String, dynamic>> userNotifications = [];

        if (existingData != null) {
          final List<dynamic> decoded = jsonDecode(existingData);
          userNotifications =
              decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        }

        // Check for duplicates based on bookingId and title
        final notificationId =
            '${event.bookingId}_${event.title}_${event.userId}';
        final isDuplicate = userNotifications.any((notification) =>
            notification['bookingId'] == event.bookingId &&
            notification['title'] == event.title &&
            notification['userId'] == event.userId);

        if (isDuplicate) {
          print('⚠️ Duplicate notification detected, skipping: ${event.title}');
          emit(NotificationLoaded(userNotifications));
          return;
        }

        // Create new notification
        final Map<String, dynamic> newNotification = {
          'title': event.title,
          'body': event.body,
          'status': event.status,
          'time': event.time,
          'userId': event.userId,
          'bookingId': event.bookingId,
          'id': notificationId, // Add unique ID for tracking
        };

        // Add to beginning of list
        userNotifications.insert(0, newNotification);

        // Save back to SharedPreferences with user-specific key
        await prefs.setString(notificationKey, jsonEncode(userNotifications));
        print('💾 Saved notification: ${event.title} for user ${event.userId}');

        emit(NotificationLoaded(userNotifications));
      } catch (e) {
        print('❌ Error adding notification: $e');
        _logger.e('Error adding notification: $e');
        emit(NotificationError(message: e.toString()));
      }
    });
    on<GetNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        print('🔍 Getting notifications for user: ${event.userId}');

        // Load from SharedPreferences using user-specific key
        final prefs = await SharedPreferences.getInstance();
        final String notificationKey = 'notifications_${event.userId}';
        final String? storedData = prefs.getString(notificationKey);

        if (storedData != null) {
          print(
              '📦 Found stored notifications for user ${event.userId}: $storedData');
          final List<dynamic> decodedList = jsonDecode(storedData);

          // Convert to list of maps and fix any notifications with missing body
          final notifications = decodedList.map((item) {
            final notification = Map<String, dynamic>.from(item);

            // Fix notifications that don't have proper body
            if (notification['body'] == null ||
                notification['body'].toString().contains('T') &&
                    notification['body'].toString().contains('Z')) {
              // This looks like a timestamp, let's fix it
              print(
                  '🔧 Fixing notification with timestamp as body: ${notification['title']}');

              final title = notification['title'] ?? '';
              if (title.toLowerCase().contains('confirmed')) {
                // This is from booking helper, keep it as is but ensure it has a proper body
                if (notification['body'] == null) {
                  notification['body'] = 'Your booking has been confirmed';
                }
              } else if (title.toLowerCase().contains('approved')) {
                notification['body'] = 'Your appointment has been approved';
              } else if (title.toLowerCase().contains('declined')) {
                notification['body'] = 'Your appointment has been declined';
              } else {
                notification['body'] = 'Booking status updated';
              }

              print('🔧 Fixed body: ${notification['body']}');
            }

            return notification;
          }).toList();

          // Save the fixed notifications back
          await prefs.setString(notificationKey, jsonEncode(notifications));

          print(
              '✅ Found ${notifications.length} notifications for user ${event.userId}');
          print('📝 Notifications:');
          for (var notif in notifications) {
            print(
                '  - ${notif['title']} | Body: ${notif['body']} (ID: ${notif['bookingId']})');
          }

          emit(NotificationLoaded(notifications));
        } else {
          print('❌ No notifications found for user ${event.userId}');
          emit(NotificationLoaded([]));
        }
      } catch (e) {
        _logger.e('Error getting notifications: $e');
        emit(NotificationError(message: e.toString()));
      }
    });
    on<ClearNotifications>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String notificationKey = 'notifications_${event.userId}';

        // Simply remove the user-specific notifications
        await prefs.remove(notificationKey);
        print('🧹 Cleared all notifications for user ${event.userId}');

        emit(NotificationLoaded([]));
      } catch (e) {
        _logger.e('Error clearing notifications: $e');
        emit(NotificationError(message: e.toString()));
      }
    }); // Handler for the new event to fetch notifications from the API
    on<FetchNotificationsFromApi>((event, emit) async {
      // Prevent duplicate API calls
      if (_isFetchingFromApi) {
        print('⚠️ API fetch already in progress, skipping...');
        return;
      }

      _isFetchingFromApi = true;
      emit(NotificationLoading());

      try {
        print('🌐 Fetching notifications from API for user: ${event.userId}');

        // Get the authentication token
        final token = await _authRepository.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found');
        }

        // Setup the API request with the token
        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        // Last check timestamp for filtering (if provided)
        final queryParams = <String, dynamic>{};
        if (event.lastCheck != null) {
          queryParams['last_check'] = event.lastCheck;
        }

        // Make the API request
        final response = await dio.get(
          'http://192.168.100.18:8000/v1/notifications/recent',
          queryParameters: queryParams,
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to fetch notifications: ${response.statusMessage}');
        }

        final data = response.data;
        if (!data['success']) {
          throw Exception('API returned error: ${data['message']}');
        }

        // Get existing notifications first
        final prefs = await SharedPreferences.getInstance();
        final String notificationKey = 'notifications_${event.userId}';
        List<Map<String, dynamic>> existingNotifications = [];
        final String? existingData = prefs.getString(notificationKey);
        if (existingData != null) {
          final List<dynamic> decoded = jsonDecode(existingData);
          existingNotifications =
              decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        }

        // Get the notifications from the response
        final List<dynamic> apiNotifications = data['notifications'];
        List<Map<String, dynamic>> newNotifications = [];

        for (var item in apiNotifications) {
          final notificationId =
              '${item['id']}_${item['status']}_${event.userId}';

          // Check if this notification already exists to prevent duplicates
          final isDuplicate = existingNotifications.any((existing) =>
              existing['bookingId'] == item['id'] &&
              existing['status'] == item['status'] &&
              existing['userId'] == event.userId);

          // Also check our processed IDs set
          if (isDuplicate ||
              _processedNotificationIds.contains(notificationId)) {
            print(
                '⚠️ Skipping duplicate notification: ${item['id']} - ${item['status']}');
            continue;
          }

          // Mark as processed
          _processedNotificationIds.add(
              notificationId); // Map the API response to the format expected by the UI
          final formattedBody = _formatNotificationDescription(item);
          print('🔧 Formatting notification:');
          print('   Original item: $item');
          print('   Formatted body: $formattedBody');

          final notification = {
            'title': 'Booking ${item['status']}',
            'body': formattedBody,
            'status': item['status'],
            'time': item['updated_at'],
            'userId': event.userId,
            'bookingId': item['id'],
            'serviceName': item['service_name'],
            'bookingDate': item['booking_date'],
            'bookingTime': item['booking_time'],
            'location': item['location'],
            'id': notificationId,
          };

          newNotifications.add(notification);

          // Show push notification for each new notification
          await _showPushNotification(
            title: notification['title'],
            body: notification['body'],
            bookingId: item['id'],
            context: event.context,
          );
        }

        // Save new notifications to SharedPreferences
        if (newNotifications.isNotEmpty) {
          // Add new notifications to the beginning (to maintain chronology)
          final allNotifications = [
            ...newNotifications,
            ...existingNotifications
          ];

          // Save back to SharedPreferences
          await prefs.setString(notificationKey, jsonEncode(allNotifications));
          print(
              '💾 Saved ${newNotifications.length} new notifications from API');

          emit(NotificationLoaded(allNotifications));
        } else {
          // If no new notifications, still return what we have
          emit(NotificationLoaded(existingNotifications));
          print('ℹ️ No new notifications found from API');
        }

        // Save the last check timestamp
        final lastCheck = data['last_check'];
        if (lastCheck != null) {
          await prefs.setString(
              'notifications_last_check_${event.userId}', lastCheck);
        }
      } catch (e) {
        print('❌ Error fetching notifications from API: $e');
        _logger.e('Error fetching notifications from API: $e');
        emit(NotificationError(message: e.toString()));
      } finally {
        _isFetchingFromApi = false;
      }
    });
  }
  // This method will be called during initialization to migrate existing data
  void _migrateNotifications() {
    Future.delayed(Duration.zero, () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? oldStoredData = prefs.getString('notifications');

        if (oldStoredData != null) {
          print('🔄 Found old notification format, migrating data...');
          final List<dynamic> decodedList = jsonDecode(oldStoredData);
          final List<Map<String, dynamic>> allNotifications = decodedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          // Group notifications by userId
          final Map<String, List<Map<String, dynamic>>> userNotifications = {};

          for (var notification in allNotifications) {
            final String userId = notification['userId'].toString();
            if (!userNotifications.containsKey(userId)) {
              userNotifications[userId] = [];
            }
            userNotifications[userId]!.add(notification);
          }

          // Save each user's notifications to their own key
          for (var userId in userNotifications.keys) {
            final String userKey = 'notifications_$userId';
            await prefs.setString(
                userKey, jsonEncode(userNotifications[userId]));
            print(
                '✅ Migrated ${userNotifications[userId]!.length} notifications for user $userId');
          }

          // Remove old global storage
          await prefs.remove('notifications');
          print('🗑️ Removed old notification storage');
        }
      } catch (e) {
        print('❌ Error migrating notifications: $e');
        _logger.e('Error migrating notifications: $e');
      }
    });
  }

  // Helper method to show push notifications
  Future<void> _showPushNotification({
    required String title,
    required String body,
    required int bookingId,
    BuildContext? context,
  }) async {
    try {
      print('🔔 Showing push notification: $title');

      // Create payload for navigation
      final payload = jsonEncode({
        'bookingId': bookingId,
        'type': 'booking',
      });

      // Show local notification
      await flutterLocalNotificationsPlugin.show(
        bookingId, // Use bookingId as notification ID
        title,
        body,
        const NotificationDetails(
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
      );
      print('✅ Push notification sent successfully');
    } catch (e) {
      print('❌ Error showing push notification: $e');
      _logger.e('Error showing push notification: $e');
    }
  }

  // Helper method to format notification description
  String _formatNotificationDescription(Map<String, dynamic> item) {
    print('🔍 Formatting description for item: $item');

    final serviceName = item['service_name']?.toString() ?? 'your service';
    final bookingDate = item['booking_date']?.toString() ?? '';
    final bookingTime = item['booking_time']?.toString() ?? '';
    final status = item['status']?.toString().toLowerCase() ?? 'updated';
    final location = item['location']?.toString() ?? '';
    final message = item['message']?.toString() ?? '';

    print(
        '🔍 Extracted data: serviceName=$serviceName, date=$bookingDate, time=$bookingTime, status=$status, location=$location, message=$message');

    String description;

    // If there's a custom message from API, use it as base
    if (message.isNotEmpty && message != 'null') {
      description = message;
    } else {
      description = 'Your appointment for $serviceName has been $status';

      if (bookingDate.isNotEmpty &&
          bookingDate != 'null' &&
          bookingTime.isNotEmpty &&
          bookingTime != 'null') {
        description += ' for $bookingDate at $bookingTime';
      }

      if (location.isNotEmpty && location != 'null') {
        description += ' at $location';
      }
    }

    print('🔍 Final description: $description');
    return description;
  }
}
