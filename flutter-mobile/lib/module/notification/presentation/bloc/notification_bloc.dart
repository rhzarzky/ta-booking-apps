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

    on<AddNotification>((event, emit) async {
      print('📥 Adding new notification: ${event.title}');
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);
      emit(NotificationLoading());
      try {
        // Get current notifications from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? existingData = prefs.getString('notifications');
        List<Map<String, dynamic>> allNotifications = [];

        if (existingData != null) {
          final List<dynamic> decoded = jsonDecode(existingData);
          allNotifications =
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
        allNotifications.insert(0, newNotification);

        // Save back to SharedPreferences
        await prefs.setString('notifications', jsonEncode(allNotifications));
        print('💾 Saved notification: ${event.title} for user ${event.userId}');

        // Emit only notifications for this user
        final userNotifications = allNotifications
            .where((n) => n['userId'].toString() == event.userId)
            .toList();
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

        // Load from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? storedData = prefs.getString('notifications');

        if (storedData != null) {
          print('📦 Found stored notifications: $storedData');
          final List<dynamic> decodedList = jsonDecode(storedData);

          // Convert to list of maps and filter by userId
          final notifications = decodedList
              .map((item) => Map<String, dynamic>.from(item))
              .where((notif) => notif['userId'].toString() == event.userId)
              .toList();

          print(
              '✅ Found ${notifications.length} notifications for user ${event.userId}');
          print('📝 Notifications:');
          for (var notif in notifications) {
            print('  - ${notif['title']} (ID: ${notif['bookingId']})');
          }

          emit(NotificationLoaded(notifications));
        } else {
          print('❌ No notifications found in storage');
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
        final String? storedData = prefs.getString('notifications');

        if (storedData != null) {
          final List<dynamic> decodedList = jsonDecode(storedData);
          final List<Map<String, dynamic>> allNotifications = decodedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          // Remove notifications for this user
          final filteredNotifications = allNotifications
              .where((notif) => notif['userId'].toString() != event.userId)
              .toList();

          // Save back to SharedPreferences
          await prefs.setString(
              'notifications', jsonEncode(filteredNotifications));

          emit(NotificationLoaded([]));
        }
      } catch (e) {
        _logger.e('Error clearing notifications: $e');
        emit(NotificationError(message: e.toString()));
      }
    });
  }

  Future<void> _saveNotifications(
      List<Map<String, dynamic>> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = jsonEncode(notifications);
      await prefs.setString('notifications', notificationsJson);
      print('💾 Saved ${notifications.length} notifications to storage');
      _logger.d('Successfully saved notifications');
    } catch (e) {
      print('❌ Error saving notifications: $e');
      _logger.e('Error saving notifications: $e');
    }
  }
}
