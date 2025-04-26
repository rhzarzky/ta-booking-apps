import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<AddNotification>((event, emit) async {
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);
      emit(NotificationLoading());
      try {
        await Future.delayed(const Duration(microseconds: 300));
        currentNotifications.insert(0, {
          'title': event.title,
          'body': event.body,
          'status': event.status,
          'time': event.time,
          'userId': event.userId,
        });

        emit(NotificationLoaded(currentNotifications));
      } catch (e) {
        emit(NotificationError(message: e.toString()));
      }
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
