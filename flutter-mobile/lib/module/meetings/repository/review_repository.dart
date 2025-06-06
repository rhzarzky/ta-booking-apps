import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/meetings/model/reviews_model.dart';
import 'package:Appointly/module/meetings/model/service_reviews_model.dart';
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

      _logger.i('Fetching review for booking ID: $bookingId');
      final response = await _dio.get('/booking/$bookingId/review');

      _logger.i('Get review response status: ${response.statusCode}');
      _logger.i('Get review response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Handle nested structure: {success: true, data: {review: {...}, booking: {...}}}
          if (responseData.containsKey('data') &&
              responseData['data'] is Map &&
              responseData['data']['review'] is Map) {
            final reviewData = responseData['data']['review'];
            _logger.i('Found review data: $reviewData');
            return ReviewsModel.fromJson(reviewData);
          }
          // Handle alternative structure: {success: true, data: {...}} where data is the review directly
          else if (responseData.containsKey('data') &&
              responseData['data'] is Map) {
            final dataSection = responseData['data'];
            _logger.i('Using data section as review: $dataSection');
            return ReviewsModel.fromJson(dataSection);
          }
          // Handle direct review object
          else {
            _logger.i('Using response data directly: $responseData');
            return ReviewsModel.fromJson(responseData);
          }
        } else {
          _logger.w('Unexpected response format: ${responseData.runtimeType}');
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 404) {
        _logger.w('Review not found for booking ID: $bookingId');
        throw Exception('Review not found for this booking');
      } else {
        throw Exception('Failed to load review: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in getReview: $e');
      rethrow;
    }
  }

  Future<List<ReviewsModel>> getAllReview() async {
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

      _logger.i('Fetching all reviews...');
      final response = await _dio.get('/user/reviews');

      _logger.i('Get all reviews response status: ${response.statusCode}');
      _logger.i('Get all reviews response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Handle API response structure: {success: true, data: [...]}
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            final List<dynamic> reviewsList = responseData['data'];
            _logger.i('Found ${reviewsList.length} reviews in response');
            return reviewsList
                .map((json) => ReviewsModel.fromJson(json))
                .toList();
          }
          // Handle alternative structure: {reviews: [...]}
          else if (responseData.containsKey('reviews') &&
              responseData['reviews'] is List) {
            final List<dynamic> reviewsList = responseData['reviews'];
            return reviewsList
                .map((json) => ReviewsModel.fromJson(json))
                .toList();
          }
          // Single review object
          else {
            return [ReviewsModel.fromJson(responseData)];
          }
        }
        // Direct array response
        else if (responseData is List) {
          return responseData
              .map((json) => ReviewsModel.fromJson(json))
              .toList();
        }
        // Fallback
        else {
          _logger.w('Unexpected response format: ${responseData.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Failed to load reviews: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceReviewsModel> getServiceReviews(int serviceId) async {
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

      final result = await _dio.get('/service/$serviceId/reviews');
      if (result.statusCode == 200) {
        final responseData = result.data;

        // Handle API response structure: {success: true, data: {...}}
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return ServiceReviewsModel.fromJson(responseData['data']);
        } else {
          return ServiceReviewsModel.fromJson(responseData);
        }
      } else {
        throw Exception(
            'Failed to load service reviews: ${result.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in getServiceReviews: $e');
      throw Exception('Failed to load service reviews: ${e.toString()}');
    }
  }
}
