part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class AddNotification extends NotificationEvent {
  final String title;
  final String body;
  final String status;
  final String time;
  final String userId;
  final int bookingId;

  AddNotification({
    required this.title,
    required this.body,
    required this.status,
    required this.time,
    required this.userId,
    this.bookingId = 0,
  });
}

class GetNotifications extends NotificationEvent {
  final String userId;

  GetNotifications({
    required this.userId,
  });
}

class ClearNotifications extends NotificationEvent {
  final String userId;

  ClearNotifications({
    required this.userId,
  });
}

class FetchNotificationsFromApi extends NotificationEvent {
  final String userId;
  final String? lastCheck;

  FetchNotificationsFromApi({
    required this.userId,
    this.lastCheck,
  });
}
