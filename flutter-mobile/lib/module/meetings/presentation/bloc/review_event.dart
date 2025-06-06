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
  final int bookingId;
  final int rating;
  final String comment;
  final int userId;

  const SubmitReviewEvent({
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.userId,
  });

  @override
  List<Object?> get props => [bookingId, rating, comment, userId];
}

class GetReviewEvent extends ReviewEvent {
  final int bookingId;

  const GetReviewEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
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
