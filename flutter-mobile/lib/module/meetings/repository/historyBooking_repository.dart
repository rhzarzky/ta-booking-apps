import 'package:Appointly/module/meetings/model/booking_detail_model.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class HistorybookingRepository {
  final Dio _dio;
  final Logger _logger = Logger();

  HistorybookingRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://192.168.100.18:8000/v1',
          headers: {'Content-type': 'application/json'},
          validateStatus: (status) => status! < 500,
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ));

  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<BookingResponse> getAllBookings() async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      final response = await _dio.get('/booking');

      if (response.statusCode == 200) {
        _logger.d('Response: ${response.data}');
        return BookingResponse.fromJson(response.data);
      } else {
        _logger.e('Failed to load bookings: ${response.statusMessage}');
        throw Exception('Failed to load bookings: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error: $e');
      rethrow;
    }
  }

  Future<BookingDetail> getBookingById(int idBooking) async {
    try {
      _logger.d('Fetching booking with ID: $idBooking');

      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          throw Exception('No authorization token found');
        }
      }

      final response = await _dio.get('/booking/$idBooking');

      if (response.statusCode == 200) {
        _logger.d('Response: ${response.data}');

        if (response.data == null) {
          throw Exception('No data received from server');
        }

        if (response.data['services'] is List &&
            (response.data['services'] as List).isEmpty) {
          // Create an empty booking with user data
          return BookingDetail.fromEmptyResponse(
              response.data['user'] as Map<String, dynamic>, idBooking);
        }

        // Handle different response structures
        Map<String, dynamic> bookingData;
        if (response.data['booking'] != null) {
          bookingData = response.data['booking'];
        } else if (response.data['services'] != null) {
          return BookingDetail.fromRawResponse(response.data);
        } else {
          bookingData = response.data;
        }

        return BookingDetail.fromJson(bookingData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to fetch booking: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error in getBookingById: $e');
      rethrow;
    }
  }

  Future<Booking> createBooking(Booking booking) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      final response = await _dio.post('/booking', data: {
        'user_id': booking.user.id,
        'service': {
          'title': booking.service.title,
          'description': booking.service.description,
          'option': booking.service.option,
          'day': booking.service.day,
          'time': booking.service.time,
          'status': booking.service.status,
        }
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
