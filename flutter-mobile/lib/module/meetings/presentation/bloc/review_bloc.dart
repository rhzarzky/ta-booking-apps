import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'package:Appointly/module/meetings/repository/review_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _reviewRepository;
  final Logger _logger = Logger();
  ReviewBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(ReviewInitial()) {
    on<CompleteMeetingEvent>(_onCompleteMeeting);
    on<SubmitReviewEvent>(_onSubmitReview);
    on<GetReviewEvent>(_onGetReview);
    on<GetAllReviewEvent>(_getAllReview);
    on<GetServiceReviewsEvent>(_getServiceReviews);
    on<GetUserReviewsForServiceEvent>(_getUserReviewsForService);
    on<CheckUserReviewStatusEvent>(_onCheckUserReviewStatus); // Add new handler
  }

  Future<void> _onCompleteMeeting(
    CompleteMeetingEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result =
          await _reviewRepository.postCompleteMeeting(event.bookingId);

      emit(CompleteMeetingSuccess(completeMeeting: result));
      _logger
          .i('Meeting completed successfully for booking ${event.bookingId}');
    } catch (e) {
      _logger.e('Error completing meeting: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result = await _reviewRepository.postReview(
        event.serviceId, // Use serviceId for the API endpoint
        event.rating,
        event.comment,
        event.userId,
        bookingId: event.bookingId, // Pass bookingId for proper tracking
      );

      emit(SubmitReviewSuccess(review: result));
      _logger.i(
          'Review submitted successfully for service ${event.serviceId}${event.bookingId != null ? ', booking ${event.bookingId}' : ''}');
    } catch (e) {
      _logger.e('Error submitting review: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _onGetReview(
    GetReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result =
          await _reviewRepository.getReview(event.serviceId, event.userId);

      emit(GetReviewSuccess(review: result));
      _logger.i(
          'Review fetched successfully for service ${event.serviceId}, user ${event.userId}');
    } catch (e) {
      _logger.e('Error fetching review: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _getAllReview(
    GetAllReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result = await _reviewRepository.getAllReview();

      emit(GetAllReviewSuccess(reviews: result));
      _logger.i('All reviews fetched successfully');
    } catch (e) {
      _logger.e('Error fetching all reviews: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _getServiceReviews(
    GetServiceReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result = await _reviewRepository.getServiceReviews(event.serviceId);

      emit(GetServiceReviewsSuccess(
        serviceReviews: result,
        serviceId: event.serviceId, // Sertakan service ID dalam response
      ));
      _logger.i(
          'Service reviews fetched successfully for service ${event.serviceId}');
    } catch (e) {
      _logger.e('Error fetching service reviews: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _getUserReviewsForService(
    GetUserReviewsForServiceEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoading());

      final result = await _reviewRepository.getUserReviewsForService(
        event.serviceId,
        event.userId,
      );

      emit(GetUserReviewsForServiceSuccess(
        userReviews: result,
        serviceId: event.serviceId,
        userId: event.userId,
      ));
      _logger.i(
          'User reviews fetched successfully for service ${event.serviceId}, user ${event.userId}: ${result.length} reviews');
    } catch (e) {
      _logger.e('Error fetching user reviews for service: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }

  Future<void> _onCheckUserReviewStatus(
    CheckUserReviewStatusEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final hasReviewed = await _reviewRepository.isBookingReviewed(
        event.serviceId,
        event.userId,
      );

      emit(CheckUserReviewStatusSuccess(
        hasReviewed: hasReviewed,
        serviceId: event.serviceId,
        userId: event.userId,
      ));

      _logger.i(
          'Review status checked for service ${event.serviceId}, user ${event.userId}: $hasReviewed');
    } catch (e) {
      _logger.e('Error checking user review status: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }
}
