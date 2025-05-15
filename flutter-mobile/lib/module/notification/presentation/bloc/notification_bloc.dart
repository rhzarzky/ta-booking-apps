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
    // Load notifications dari SharedPreferences saat inisialisasi
    _loadSavedNotifications();

    on<AddNotification>((event, emit) async {
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);
      emit(NotificationLoading());
      try {
        await Future.delayed(
          Duration(
            milliseconds: 300,
          ),
        );

        // Tambahkan notifikasi baru
        final Map<String, dynamic> newNotification = {
          'title': event.title,
          'body': event.body,
          'status': event.status,
          'time': event.time,
          'userId': event.userId,
          'bookingId': event.bookingId,
        };

        _logger.d('Menambahkan notifikasi: $newNotification');
        currentNotifications.insert(0, newNotification);

        // Simpan ke SharedPreferences untuk persistensi
        _saveNotifications(currentNotifications);

        emit(NotificationLoaded(currentNotifications));
      } catch (e) {
        _logger.e('Error adding notification: $e');
        emit(NotificationError(message: e.toString()));
      }
    });

    on<GetNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        await Future.delayed(
          Duration(
            milliseconds: 300,
          ),
        );
        final currentNotifications =
            List<Map<String, dynamic>>.from(state.notifications);

        _logger.d(
            'Memuat ${currentNotifications.length} notifikasi, userId: ${event.userId}');

        // Debug: Cetak semua notifikasi yang ada
        for (var notif in currentNotifications) {
          _logger.d(
              'Notifikasi: ${notif['title']} - userId: ${notif['userId']} - bookingId: ${notif['bookingId']}');
        }

        emit(NotificationLoaded(currentNotifications));
      } catch (e) {
        _logger.e('Error getting notifications: $e');
        emit(NotificationError(message: e.toString()));
      }
    });

    on<ClearNotifications>((event, emit) {
      final currentNotifications =
          List<Map<String, dynamic>>.from(state.notifications);
      currentNotifications.removeWhere(
          (notification) => notification['userId'] == event.userId);

      // Simpan perubahan ke SharedPreferences
      _saveNotifications(currentNotifications);

      emit(NotificationLoaded(currentNotifications));
    });
  }

  // Simpan notifikasi ke SharedPreferences
  Future<void> _saveNotifications(
      List<Map<String, dynamic>> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = jsonEncode(notifications);
      await prefs.setString('notifications', notificationsJson);
      _logger.d('Berhasil menyimpan ${notifications.length} notifikasi');
    } catch (e) {
      _logger.e('Error saving notifications: $e');
    }
  }

  // Muat notifikasi dari SharedPreferences
  Future<void> _loadSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('notifications');

      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(notificationsJson);
        final List<Map<String, dynamic>> notificationsList =
            decodedList.map((item) => Map<String, dynamic>.from(item)).toList();

        _logger.d(
            'Berhasil memuat ${notificationsList.length} notifikasi dari penyimpanan');
        emit(NotificationLoaded(notificationsList));
      } else {
        _logger.d('Tidak ada notifikasi tersimpan');
        emit(NotificationLoaded([]));
      }
    } catch (e) {
      _logger.e('Error loading notifications: $e');
      emit(NotificationError(message: e.toString()));
    }
  }
}
