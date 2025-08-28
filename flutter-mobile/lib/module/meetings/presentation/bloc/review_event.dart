import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class CompleteMeetingEvent extends ReviewEvent {
  final int bookingId;

  const CompleteMeetingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class SubmitReviewEvent extends ReviewEvent {
  final int serviceId; // Service ID for the review endpoint
  final int? bookingId; // Optional booking ID for tracking specific booking
  final int rating;
  final String comment;
  final int userId;

  const SubmitReviewEvent({
    required this.serviceId,
    this.bookingId, // Optional parameter
    required this.rating,
    required this.comment,
    required this.userId,
  });

  @override
  List<Object?> get props => [serviceId, bookingId, rating, comment, userId];
}

class GetReviewEvent extends ReviewEvent {
  final int serviceId;
  final int userId;

  const GetReviewEvent({required this.serviceId, required this.userId});

  @override
  List<Object?> get props => [serviceId, userId];
}

class GetAllReviewEvent extends ReviewEvent {
  const GetAllReviewEvent();
}

class GetServiceReviewsEvent extends ReviewEvent {
  final int serviceId;

  const GetServiceReviewsEvent({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

class GetUserReviewsForServiceEvent extends ReviewEvent {
  final int serviceId;
  final int userId;

  const GetUserReviewsForServiceEvent({
    required this.serviceId,
    required this.userId,
  });

  @override
  List<Object?> get props => [serviceId, userId];
}

class CheckUserReviewStatusEvent extends ReviewEvent {
  final int serviceId;
  final int userId;

  const CheckUserReviewStatusEvent({
    required this.serviceId,
    required this.userId,
  });

  @override
  List<Object?> get props => [serviceId, userId];
}
