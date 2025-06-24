import 'package:Appointly/module/meetings/model/reviews_model.dart';

class ServiceReviewsModel {
  final List<ReviewsModel> reviews;
  final double averageRating;
  final int totalReviews;

  ServiceReviewsModel({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });
  factory ServiceReviewsModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Parsing ServiceReviewsModel from JSON: $json');

      // Extract reviews list and handle nested user structure
      List<ReviewsModel> reviewsList = [];

      // Try different possible locations for reviews data
      if (json.containsKey('reviews') && json['reviews'] is List) {
        // Direct reviews array
        final reviewsData = json['reviews'] as List<dynamic>;
        reviewsList = reviewsData.map((review) {
          return ReviewsModel.fromJson(review);
        }).toList();
        print('📝 Found ${reviewsList.length} reviews in direct reviews array');
      } else if (json.containsKey('data') && json['data'] is Map) {
        // Nested in data object
        final data = json['data'] as Map<String, dynamic>;
        if (data.containsKey('reviews') && data['reviews'] is List) {
          final reviewsData = data['reviews'] as List<dynamic>;
          reviewsList = reviewsData.map((review) {
            return ReviewsModel.fromJson(review);
          }).toList();
          print('📝 Found ${reviewsList.length} reviews in data.reviews array');
        }
      }

      // Calculate average rating from reviews
      double avgRating = 0.0;
      if (reviewsList.isNotEmpty) {
        final validRatings = reviewsList
            .where((review) => review.rating != null && review.rating! > 0)
            .map((review) => review.rating!)
            .toList();

        if (validRatings.isNotEmpty) {
          final totalRating =
              validRatings.reduce((sum, rating) => sum + rating);
          avgRating = totalRating / validRatings.length;
        }
      }

      // Get total reviews count
      final totalCount = reviewsList.length;

      // Use provided values if available, otherwise use calculated values
      final finalAvgRating = json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : avgRating;
      final finalTotalReviews = json['total_reviews'] as int? ?? totalCount;

      print(
          '📊 Final stats: $finalTotalReviews reviews, $finalAvgRating avg rating');

      return ServiceReviewsModel(
        reviews: reviewsList,
        averageRating: finalAvgRating,
        totalReviews: finalTotalReviews,
      );
    } catch (e) {
      // Return empty model if parsing fails
      print('❌ Error parsing ServiceReviewsModel: $e');
      return ServiceReviewsModel(
        reviews: [],
        averageRating: 0.0,
        totalReviews: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
