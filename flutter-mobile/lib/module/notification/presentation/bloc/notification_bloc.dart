import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final Logger _logger = Logger();

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

        // Create new notification
        final Map<String, dynamic> newNotification = {
          'title': event.title,
          'body': event.body,
          'status': event.status,
          'time': event.time,
          'userId': event.userId,
          'bookingId': event.bookingId,
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

          // Convert to list of maps - no need to filter as these are already user-specific
          final notifications = decodedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          print(
              '✅ Found ${notifications.length} notifications for user ${event.userId}');
          print('📝 Notifications:');
          for (var notif in notifications) {
            print('  - ${notif['title']} (ID: ${notif['bookingId']})');
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
}
