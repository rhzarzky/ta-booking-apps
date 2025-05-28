import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/meetings/model/reviews_model.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewRepository {
  final Dio _dio = ApiService.instance;
  final Logger _logger = Logger();

  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<CompleteMeeting> postCompleteMeeting(int bookingId) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          _logger.w('No token available for service request');
        }
      }

      _logger.i('Sending complete meeting request for booking ID: $bookingId');
      final response = await _dio.post('/booking/$bookingId/complete');

      _logger.i('Complete meeting response status: ${response.statusCode}');
      _logger.i('Complete meeting response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response structures
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // If response has 'data' field, use it; otherwise use the response directly
          final dataToUse = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return CompleteMeeting.fromJson(dataToUse);
        } else {
          // If response is not a map, create a simple success response
          return CompleteMeeting(
            bookingId: bookingId,
            status: 'completed',
            message: 'Meeting marked as completed successfully',
          );
        }
      } else {
        throw Exception(
            'Failed to complete meeting: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in postCompleteMeeting: $e');
      rethrow;
    }
  }

  Future<ReviewsModel> postReview(
      int bookingId, int rating, String comment, int userId) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          _logger.w('No token available for service request');
        }
      }

      _logger.i('Sending review for booking ID: $bookingId, rating: $rating');
      final response = await _dio.post('/booking/$bookingId/review', data: {
        'rating': rating,
        'comment': comment,
      });

      _logger.i('Review response status: ${response.statusCode}');
      _logger.i('Review response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response structures
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // If response has 'data' field, use it; otherwise use the response directly
          final dataToUse = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ReviewsModel.fromJson(dataToUse);
        } else {
          throw Exception('Invalid response format for review submission');
        }
      } else {
        throw Exception('Failed to submit review: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in postReview: $e');
      rethrow;
    }
  }

  Future<ReviewsModel> getReview(int bookingId) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          _logger.w('No token available for service request');
        }
      }

      final response = await _dio.get('/booking/$bookingId/review');

      if (response.statusCode == 200) {
        return ReviewsModel.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load complete meeting: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
