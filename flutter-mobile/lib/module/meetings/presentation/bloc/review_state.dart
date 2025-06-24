import 'package:Appointly/module/meetings/model/reviews_model.dart';
import 'package:Appointly/module/meetings/model/service_reviews_model.dart';
import 'package:equatable/equatable.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class CompleteMeetingSuccess extends ReviewState {
  final CompleteMeeting completeMeeting;

  const CompleteMeetingSuccess({required this.completeMeeting});

  @override
  List<Object?> get props => [completeMeeting];
}

class SubmitReviewSuccess extends ReviewState {
  final ReviewsModel review;

  const SubmitReviewSuccess({required this.review});

  @override
  List<Object?> get props => [review];
}

class GetReviewSuccess extends ReviewState {
  final ReviewsModel review;

  const GetReviewSuccess({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewFailure extends ReviewState {
  final String error;

  const ReviewFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class GetAllReviewSuccess extends ReviewState {
  final List<ReviewsModel> reviews;

  const GetAllReviewSuccess({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class GetServiceReviewsSuccess extends ReviewState {
  final ServiceReviewsModel serviceReviews;
  final int serviceId; // Tambahkan service ID untuk tracking

  const GetServiceReviewsSuccess({
    required this.serviceReviews,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [serviceReviews, serviceId];
}
