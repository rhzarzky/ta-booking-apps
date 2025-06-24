part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoaded extends BookingState {
  final List<Booking> approved;
  final List<Booking> pending;
  final List<Booking> declined;
  final Map<String, int> stats;
  final bool isFiltered;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final int? month;
  final int? year;

  final BookingDetail? bookingDetail;

  BookingLoaded({
    required this.approved,
    required this.pending,
    required this.declined,
    this.bookingDetail,
    this.stats = const {},
    this.isFiltered = false,
    this.filterStartDate,
    this.filterEndDate,
    this.month,
    this.year,
  });
}

final class BookingLoading extends BookingState {}

final class BookingSuccess extends BookingState {
  final Bookings bookings;

  BookingSuccess(this.bookings);
}

final class BookingFailure extends BookingState {
  final String failure;

  BookingFailure({required this.failure});
}
