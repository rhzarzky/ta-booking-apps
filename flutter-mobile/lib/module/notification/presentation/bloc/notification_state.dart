part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {
  final List<Map<String, dynamic>> notifications;
  const NotificationState({this.notifications = const []});
}

class NotificationInitial extends NotificationState {
  const NotificationInitial() : super(notifications: const []);
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(List<Map<String, dynamic>> notifications)
      : super(notifications: notifications);
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message) : super(notifications: const []);
}
