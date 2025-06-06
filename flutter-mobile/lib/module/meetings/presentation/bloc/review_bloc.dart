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
        event.bookingId,
        event.rating,
        event.comment,
        event.userId,
      );

      emit(SubmitReviewSuccess(review: result));
      _logger.i('Review submitted successfully for booking ${event.bookingId}');
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

      final result = await _reviewRepository.getReview(event.bookingId);

      emit(GetReviewSuccess(review: result));
      _logger.i('Review fetched successfully for booking ${event.bookingId}');
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

      emit(GetServiceReviewsSuccess(serviceReviews: result));
      _logger.i(
          'Service reviews fetched successfully for service ${event.serviceId}');
    } catch (e) {
      _logger.e('Error fetching service reviews: $e');
      emit(ReviewFailure(error: e.toString()));
    }
  }
}
