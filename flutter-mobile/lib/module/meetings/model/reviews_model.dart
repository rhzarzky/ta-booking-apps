import 'package:flutter/material.dart';

class ReviewsModel {
  final int? id;
  final int bookingId;
  final int userId;
  final int? rating;
  final String? comment;
  final ReviewStatus status;
  final DateTime? completedAt;
  final DateTime? reviewDeadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewsModel({
    this.id,
    required this.bookingId,
    required this.userId,
    this.rating,
    this.comment,
    this.status = ReviewStatus.pending,
    this.completedAt,
    this.reviewDeadline,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat Review dari JSON
  factory ReviewsModel.fromJson(Map<String, dynamic> json) {
    return ReviewsModel(
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()))
          : null,
      bookingId: json['booking_id'] != null
          ? (json['booking_id'] is int
              ? json['booking_id']
              : int.tryParse(json['booking_id'].toString()) ?? 0)
          : 0,
      userId: json['user_id'] != null
          ? (json['user_id'] is int
              ? json['user_id']
              : int.tryParse(json['user_id'].toString()) ?? 0)
          : 0,
      rating: json['rating'] != null
          ? (json['rating'] is int
              ? json['rating']
              : int.tryParse(json['rating'].toString()))
          : null,
      comment: json['comment']?.toString(),
      status: ReviewStatus.fromString(json['status']?.toString() ?? 'pending'),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      reviewDeadline: json['review_deadline'] != null
          ? DateTime.tryParse(json['review_deadline'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // Method untuk convert Review ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'status': status.value,
      'completed_at': completedAt?.toIso8601String(),
      'review_deadline': reviewDeadline?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Method untuk membuat copy dengan perubahan
  ReviewsModel copyWith({
    int? id,
    int? bookingId,
    int? userId,
    int? rating,
    String? comment,
    ReviewStatus? status,
    DateTime? completedAt,
    DateTime? reviewDeadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewsModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      reviewDeadline: reviewDeadline ?? this.reviewDeadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get hasRating => rating != null && rating! > 0;
  bool get hasComment => comment != null && comment!.isNotEmpty;
  bool get isCompleted => status == ReviewStatus.submitted;
  bool get isPending => status == ReviewStatus.pending;
  bool get isDeclined => status == ReviewStatus.declined;

  // Check if review deadline has passed
  bool get isDeadlinePassed {
    if (reviewDeadline == null) return false;
    return DateTime.now().isAfter(reviewDeadline!);
  }

  // Get days remaining until deadline
  int? get daysUntilDeadline {
    if (reviewDeadline == null) return null;
    final difference = reviewDeadline!.difference(DateTime.now());
    return difference.inDays;
  }

  @override
  String toString() {
    return 'Review{id: $id, bookingId: $bookingId, userId: $userId, rating: $rating, status: ${status.value},}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum untuk status review
enum ReviewStatus {
  pending('pending'),
  submitted('submitted'),
  declined('declined');

  const ReviewStatus(this.value);
  final String value;

  static ReviewStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReviewStatus.pending;
      case 'submitted':
        return ReviewStatus.submitted;
      case 'declined':
        return ReviewStatus.declined;
      default:
        return ReviewStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ReviewStatus.pending:
        return 'Pending';
      case ReviewStatus.submitted:
        return 'Submitted';
      case ReviewStatus.declined:
        return 'Declined';
    }
  }

  // Get color for status display
  Color get color {
    switch (this) {
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.submitted:
        return Colors.green;
      case ReviewStatus.declined:
        return Colors.red;
    }
  }
}

// Optional: Class untuk request review submission
class ReviewRequest {
  final int bookingId;
  final int? rating;
  final String? comment;

  ReviewRequest({
    required this.bookingId,
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }

  bool get isValid => rating != null && rating! >= 1 && rating! <= 5;
}

// Optional: Class untuk response dari API
class ReviewResponse {
  final bool success;
  final String message;
  final ReviewsModel? review;
  final List<String>? errors;

  ReviewResponse({
    required this.success,
    required this.message,
    this.review,
    this.errors,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      review: json['data'] != null ? ReviewsModel.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class CompleteMeeting {
  final int? bookingId;
  final String? status;
  final String? message;

  CompleteMeeting({
    this.bookingId,
    this.status,
    this.message,
  });

  factory CompleteMeeting.fromJson(Map<String, dynamic> json) {
    return CompleteMeeting(
      bookingId: json['booking_id'] != null
          ? (json['booking_id'] is int
              ? json['booking_id']
              : int.tryParse(json['booking_id'].toString()))
          : null,
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'status': status,
      'message': message,
    };
  }
}
