import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class HistorybookingRepository {
  final Dio _dio = ApiService.instance;
  final Logger _logger = Logger();

  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<BookingModel> getAllBookings({int? month, int? year}) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      // Build query parameters if month or year are provided
      Map<String, dynamic> queryParams = {};
      if (month != null) {
        queryParams['month'] = month.toString();
      }
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      final response = await _dio.get(
        '/user/booking',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('Booking data: ${response.data}');
        return BookingModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load bookings: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in getAllBookings: $e');
      rethrow;
    }
  }

  Future<BookingDetailModel> getBookingDetailResponse(int id) async {
    try {
      _logger.d('Fetching booking with ID: $id');

      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          _logger.w('No token available for service request');
        }
      }

      final response = await _dio.get('/booking/$id');

      if (response.statusCode == 200) {
        _logger.i('Response in booking detail: ${response.data}');

        if (response.data == null) {
          throw Exception('No data received from server');
        }

        return BookingDetailModel.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to fetch booking: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error in getBookingDetailResponse: $e');
      rethrow;
    }
  }

  Future<Booking> createBooking(int userId, Booking booking) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      final response = await _dio.post('/booking', data: {
        'user_id': userId,
        'service': {
          'id_service': booking.service.id,
          'title': booking.service.title,
          'description': booking.service.description,
          'location': booking.service.location,
          'image': booking.service.image,
        },
        'option': booking.option,
        'date': booking.date,
        'time': booking.time,
        'note': booking.note,
        'status': booking.status,
      });

      if (response.statusCode == 201) {
        _logger.d('Booking created: ${response.data}');
        return Booking.fromJson(response.data['booking']);
      } else {
        _logger.e('Failed to create booking: ${response.statusMessage}');
        throw Exception('Failed to create booking: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error creating booking: $e');
      rethrow;
    }
  }
}
