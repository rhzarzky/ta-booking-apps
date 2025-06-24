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
      // Always refresh the token to ensure we have the latest authorization
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        updateToken(token);
        _logger.i('Updated authorization token for review submission');
      } else {
        _logger.w(
            'No token available for review submission. This will likely fail.');
      }

      // Debug log the headers being sent
      _logger.i('Request headers: ${_dio.options.headers}');

      _logger.i('Sending review for service ID: $bookingId, rating: $rating');

      // Updated endpoint format - using correct service review endpoint
      final response = await _dio.post('/service/$bookingId/review',
          data: {
            'rating': rating,
            'comment': comment,
            // Add user_id to payload if the API requires it
            'user_id': userId,
          },
          options: Options(
            validateStatus: (status) =>
                true, // Accept all status codes to handle errors better
          ));

      _logger.i('Review response status: ${response.statusCode}');
      _logger.i('Review response data: ${response.data}');

      // Better error handling with status code check
      if (response.statusCode == 401 || response.statusCode == 403) {
        _logger.e('Authentication error: Status ${response.statusCode}');
        throw Exception('Authentication failed. Please log in again.');
      }

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
        String errorMessage = 'Failed to submit review';
        if (response.statusMessage != null) {
          errorMessage += ': ${response.statusMessage}';
        }
        if (response.data is Map && response.data['message'] != null) {
          errorMessage += ' - ${response.data['message']}';
        }
        _logger.e('API error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (dioError) {
      _logger.e('DioException in postReview: ${dioError.message}');
      _logger.e('Status code: ${dioError.response?.statusCode}');
      _logger.e('Response data: ${dioError.response?.data}');
      throw Exception('Network error: ${dioError.message}');
    } catch (e) {
      _logger.e('Error in postReview: $e');
      rethrow;
    }
  }

  /// Check if a specific booking has been reviewed by the user
  Future<bool> isBookingReviewed(int serviceId, int userId) async {
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

      _logger.i(
          'Checking if service $serviceId has been reviewed by user $userId...');
      final response = await _dio.get('/service/$serviceId/reviews');

      _logger.i('Check review response status: ${response.statusCode}');
      _logger.i('Check review response data: ${response.data}');

      // If we get a 200 response, check if user has reviewed
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData is Map<String, dynamic> &&
            responseData.containsKey('reviews') &&
            responseData['reviews'] is List) {
          final reviewsList = responseData['reviews'] as List;

          // Check if there's a review from the current user
          final userReview = reviewsList.any(
            (review) => review['user']['user_id'] == userId,
          );

          _logger.i('Service $serviceId reviewed by user $userId: $userReview');
          return userReview;
        }
      }

      return false;
    } on DioException catch (dioError) {
      _logger.i(
          'DioException checking review for service $serviceId: ${dioError.message}');

      // 404 means no reviews found - service not reviewed
      if (dioError.response?.statusCode == 404) {
        _logger.i('Service $serviceId has not been reviewed (404)');
        return false;
      }

      // Other errors - assume not reviewed to be safe
      _logger.w('Error checking review status, assuming not reviewed');
      return false;
    } catch (e) {
      _logger.e('Error checking if service $serviceId is reviewed: $e');
      // Assume not reviewed if there's an error
      return false;
    }
  }

  /// Get all booking IDs that have been reviewed by the current user
  Future<Set<int>> getReviewedBookingIds() async {
    try {
      final reviews = await getAllReview();
      final reviewedIds = <int>{};

      _logger.i('Raw reviews data received: ${reviews.length} reviews');

      for (int i = 0; i < reviews.length; i++) {
        final review = reviews[i];
        _logger.i(
            'Review $i: bookingId=${review.bookingId}, id=${review.id}, userId=${review.userId}');

        // Only add valid booking IDs (greater than 0)
        if (review.bookingId > 0) {
          reviewedIds.add(review.bookingId);
        } else {
          _logger.w(
              'Skipping invalid booking ID: ${review.bookingId} for review ID: ${review.id}');
        }
      }

      _logger.i(
          'Found ${reviewedIds.length} valid reviewed bookings: $reviewedIds');
      return reviewedIds;
    } catch (e) {
      _logger.e('Error getting reviewed booking IDs: $e');
      return <int>{};
    }
  }

  Future<ReviewsModel> getReview(int serviceId, int userId) async {
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

      _logger
          .i('Fetching reviews for service ID: $serviceId, user ID: $userId');
      final response = await _dio.get('/service/$serviceId/reviews');

      _logger.i('Get reviews response status: ${response.statusCode}');
      _logger.i('Get reviews response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Check if we have reviews array
          if (responseData.containsKey('reviews') &&
              responseData['reviews'] is List) {
            final reviewsList = responseData['reviews'] as List;

            // Find review from current user
            final userReview = reviewsList.firstWhere(
              (review) => review['user']['user_id'] == userId,
              orElse: () => null,
            );
            if (userReview != null) {
              _logger.i('Found user review: $userReview');
              // Convert the review data to match ReviewsModel structure
              final reviewData = {
                'id': userReview['id'],
                'user_id': userReview['user']['user_id'],
                'service_id': userReview['service_id'],
                'rating': userReview['rating'],
                'comment': userReview['comment'],
                'status': 'submitted', // Default status for service reviews
                'created_at': userReview['created_at'],
                // Add user info for ReviewsModel
                'user': {
                  'user_id': userReview['user']['user_id'],
                  'name': userReview['user']['name'],
                  'email': userReview['user']['email'],
                }
              };
              return ReviewsModel.fromJson(reviewData);
            } else {
              _logger.w(
                  'No review found from user $userId for service $serviceId');
              throw Exception('Review not found for this user');
            }
          } else {
            _logger.w('No reviews array found in response');
            throw Exception('No reviews found for this service');
          }
        } else {
          _logger.w('Unexpected response format: ${responseData.runtimeType}');
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 404) {
        _logger.w('No reviews found for service ID: $serviceId');
        throw Exception('No reviews found for this service');
      } else {
        throw Exception('Failed to load reviews: ${response.statusMessage}');
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
        _logger.w('Failed to load reviews with status: ${response.statusCode}');
        return [];
      }
    } on DioException catch (dioError) {
      _logger.e('DioException in getAllReview: ${dioError.message}');
      _logger.e('Status code: ${dioError.response?.statusCode}');
      _logger.e('Response data: ${dioError.response?.data}');

      // Handle 404 - No reviews found for user
      if (dioError.response?.statusCode == 404) {
        _logger.i('No reviews found for user, returning empty list');
        return [];
      }

      // Handle other HTTP errors - return empty list instead of throwing
      _logger.w(
          'HTTP error ${dioError.response?.statusCode}, returning empty list');
      return [];
    } catch (e) {
      _logger.e('Error in getAllReview: $e');
      // Return empty list instead of rethrowing to prevent app crashes
      return [];
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

      _logger.i('Fetching service reviews for service ID: $serviceId');
      final result = await _dio.get('/service/$serviceId/reviews');

      _logger.i('Service reviews response status: ${result.statusCode}');
      _logger.i('Service reviews response data: ${result.data}');

      if (result.statusCode == 200) {
        final responseData = result.data;

        // Handle API response structure: {status: "success", reviews: [...]}
        if (responseData is Map<String, dynamic>) {
          // Check for empty or null data first
          if (responseData.isEmpty) {
            _logger.i(
                'Empty response map, returning empty service reviews for service $serviceId');
            return ServiceReviewsModel(
              reviews: [],
              averageRating: 0.0,
              totalReviews: 0,
            );
          }

          // Try to parse as ServiceReviewsModel
          try {
            final serviceReviews = ServiceReviewsModel.fromJson(responseData);
            _logger.i(
                'Successfully parsed service reviews for service $serviceId: ${serviceReviews.reviews.length} reviews, avg rating: ${serviceReviews.averageRating}');
            return serviceReviews;
          } catch (parseError) {
            _logger.e(
                'Error parsing ServiceReviewsModel for service $serviceId: $parseError');

            // Fallback: try to extract reviews manually
            List<ReviewsModel> reviews = [];
            if (responseData.containsKey('reviews') &&
                responseData['reviews'] is List) {
              final reviewsList = responseData['reviews'] as List;
              reviews = reviewsList
                  .map((review) => ReviewsModel.fromJson(review))
                  .toList();
            } else if (responseData.containsKey('data') &&
                responseData['data'] is Map) {
              final data = responseData['data'];
              if (data.containsKey('reviews') && data['reviews'] is List) {
                final reviewsList = data['reviews'] as List;
                reviews = reviewsList
                    .map((review) => ReviewsModel.fromJson(review))
                    .toList();
              }
            }

            // Calculate average rating
            double avgRating = 0.0;
            if (reviews.isNotEmpty) {
              final validRatings = reviews
                  .where((r) => r.rating != null && r.rating! > 0)
                  .map((r) => r.rating!)
                  .toList();
              if (validRatings.isNotEmpty) {
                avgRating =
                    validRatings.reduce((a, b) => a + b) / validRatings.length;
              }
            }

            _logger.i(
                'Fallback parsing for service $serviceId: ${reviews.length} reviews, avg rating: $avgRating');
            return ServiceReviewsModel(
              reviews: reviews,
              averageRating: avgRating,
              totalReviews: reviews.length,
            );
          }
        } else if (responseData is List) {
          // Handle direct array response
          if (responseData.isEmpty) {
            _logger.i(
                'Empty array response, returning empty service reviews for service $serviceId');
            return ServiceReviewsModel(
              reviews: [],
              averageRating: 0.0,
              totalReviews: 0,
            );
          }

          // Convert array to proper format
          final reviews =
              responseData.map((item) => ReviewsModel.fromJson(item)).toList();

          // Calculate average rating
          double avgRating = 0.0;
          if (reviews.isNotEmpty) {
            final validRatings = reviews
                .where((r) => r.rating != null && r.rating! > 0)
                .map((r) => r.rating!)
                .toList();
            if (validRatings.isNotEmpty) {
              avgRating =
                  validRatings.reduce((a, b) => a + b) / validRatings.length;
            }
          }

          _logger.i(
              'Array response for service $serviceId: ${reviews.length} reviews, avg rating: $avgRating');
          return ServiceReviewsModel(
            reviews: reviews,
            averageRating: avgRating,
            totalReviews: reviews.length,
          );
        } else {
          _logger.w(
              'Invalid response format for service $serviceId: Expected Map<String, dynamic> or List, got ${responseData.runtimeType}');
          return ServiceReviewsModel(
            reviews: [],
            averageRating: 0.0,
            totalReviews: 0,
          );
        }
      } else {
        _logger.w(
            'Failed to load service reviews for service $serviceId with status: ${result.statusCode}');
        return ServiceReviewsModel(
          reviews: [],
          averageRating: 0.0,
          totalReviews: 0,
        );
      }
    } on DioException catch (dioError) {
      _logger.e(
          'DioException in getServiceReviews for service $serviceId: ${dioError.message}');
      _logger.e('Status code: ${dioError.response?.statusCode}');
      _logger.e('Response data: ${dioError.response?.data}');

      // Handle 404 - No reviews found for this service
      if (dioError.response?.statusCode == 404) {
        _logger.i(
            'No reviews found for service $serviceId, returning empty review model');
        return ServiceReviewsModel(
          reviews: [],
          averageRating: 0.0,
          totalReviews: 0,
        );
      }

      // Handle other HTTP errors - return empty model instead of throwing
      _logger.w(
          'HTTP error ${dioError.response?.statusCode} for service $serviceId, returning empty review model');
      return ServiceReviewsModel(
        reviews: [],
        averageRating: 0.0,
        totalReviews: 0,
      );
    } catch (e) {
      _logger.e('Error in getServiceReviews for service $serviceId: $e');

      // Instead of throwing, return empty reviews to prevent app crashes
      _logger.i(
          'Returning empty review model due to error for service $serviceId');
      return ServiceReviewsModel(
        reviews: [],
        averageRating: 0.0,
        totalReviews: 0,
      );
    }
  }
}
