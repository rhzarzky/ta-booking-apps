part of 'booking_bloc.dart';

@immutable
sealed class BookingEvent {}

class GetBookingEvent extends BookingEvent {}

class UpdateTokenEvent extends BookingEvent {
  final String? token;

  UpdateTokenEvent(this.token);
}

class BookAppointmentEvent extends BookingEvent {
  final int userId;
  final String userEmail;
  final String userName;
  final String title;
  final String description;
  final String date;
  final String location;
  final String time;
  final String image;
  final String note;
  final String status;

  BookAppointmentEvent({
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.location,
    required this.time,
    required this.note,
    required this.status,
  });
}

class FilterBookingsByDateRangeEvent extends BookingEvent {
  final DateTime startDate;
  final DateTime endDate;

  FilterBookingsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });
}

class FilterBookAppointmentEvent extends BookingEvent {
  final String? filterType;

  FilterBookAppointmentEvent({
    this.filterType,
  });
}

class BookAppointmentByIdEvent extends BookingEvent {
  final int idBooking;

  BookAppointmentByIdEvent({
    required this.idBooking,
  });
}
