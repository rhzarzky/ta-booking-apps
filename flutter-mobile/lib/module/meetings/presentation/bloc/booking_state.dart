part of 'booking_bloc.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoaded extends BookingState {
  final List<Booking> approved;
  final List<Booking> pending;
  final List<Booking> declined;

  final BookingDetail? bookingDetail; // Represents details of a booking

  BookingLoaded({
    required this.approved,
    required this.pending,
    required this.declined,
    this.bookingDetail,
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
