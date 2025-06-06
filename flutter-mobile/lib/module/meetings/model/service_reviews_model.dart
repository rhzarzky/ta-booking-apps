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
    return ServiceReviewsModel(
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((review) => ReviewsModel.fromJson(review))
              .toList() ??
          [],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
