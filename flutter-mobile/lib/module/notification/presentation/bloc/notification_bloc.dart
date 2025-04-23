import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<AddNotification>((event, emit) {
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);

      // Add new notification at the beginning of the list
      currentNotifications.insert(0, {
        'title': event.title,
        'body': event.body,
        'status': event.status,
        'time': event.time,
        'userId': event.userId,
      });

      emit(NotificationLoaded(currentNotifications));
    });

    on<ClearNotifications>((event, emit) {
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);
      currentNotifications.removeWhere(
          (notification) => notification['userId'] == event.userId);
      emit(NotificationLoaded(currentNotifications));
    });
  }
}
