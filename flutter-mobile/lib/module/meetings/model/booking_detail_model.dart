import 'package:Appointly/module/meetings/model/booking_model.dart';

class BookingDetailResponse {
  final String status;
  final String message;
  final UserDetail user;
  final Services services;

  BookingDetailResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.services,
  });

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) =>
      BookingDetailResponse(
        status: json['status'] as String,
        message: json['message'] as String,
        user: UserDetail.fromJson(json['user'] as Map<String, dynamic>),
        services: Services.fromJson(json['services'] as Map<String, dynamic>),
      );
}

class Services {
  final List<BookingDetail> pending;

  Services({
    required this.pending,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        pending: (json['Pending'] as List)
            .map((e) => BookingDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class UserDetail {
  final int id;
  final String email;
  final String name;

  UserDetail({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
      );
}

class BookingDetail {
  final int id;
  final Service service;
  final String option;
  final String day;
  final String time;
  final String? note;
  final String status;

  BookingDetail({
    required this.id,
    required this.service,
    required this.option,
    required this.day,
    required this.time,
    this.note,
    required this.status,
  });

  // Create a BookingDetail from an empty response
  static BookingDetail fromEmptyResponse(
      Map<String, dynamic> userData, int bookingId) {
    return BookingDetail(
      id: bookingId,
      service: Service(
        id: 0,
        title: 'No service',
        description: 'No service details available',
      ),
      option: '',
      day: '',
      time: '',
      note: null,
      status: 'pending',
    );
  }

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    try {
      return BookingDetail(
        id: json['id'] as int? ?? json['id_booking'] as int,
        service: json['service'] != null
            ? Service.fromJson(json['service'] as Map<String, dynamic>)
            : Service(
                id: json['service_id'] as int? ?? 0,
                title: json['title'] as String? ?? '',
                description: json['description'] as String? ?? '',
              ),
        option: json['option'] as String? ?? '',
        day: json['day'] as String? ?? '',
        time: json['time'] as String? ?? '',
        note: json['note'] as String?,
        status: json['status'] as String? ?? 'pending',
      );
    } catch (e) {
      throw Exception('Failed to parse booking detail: $e');
    }
  }

  // Method to get a BookingDetail from a BookingDetailResponse
  static BookingDetail fromResponse(BookingDetailResponse response) {
    if (response.services.pending.isEmpty) {
      throw Exception('No booking found in response');
    }

    final booking = response.services.pending.first;
    return booking;
  }

  // Method to get a specific booking by ID from a BookingDetailResponse
  static BookingDetail? getBookingById(
      BookingDetailResponse response, int bookingId) {
    try {
      return response.services.pending
          .firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null; // Return null if booking with specified ID is not found
    }
  }

  // Method to get all bookings from a BookingDetailResponse
  static List<BookingDetail> getAllBookings(BookingDetailResponse response) {
    return response.services.pending;
  }

  // Method to create from raw response JSON
  static BookingDetail fromRawResponse(Map<String, dynamic> json) {
    if (json['services']['Pending'] == null ||
        (json['services']['Pending'] as List).isEmpty) {
      throw Exception('No booking found in response');
    }

    final firstPending =
        (json['services']['Pending'] as List).first as Map<String, dynamic>;
    return BookingDetail(
      id: firstPending['id'] as int,
      service:
          Service.fromJson(firstPending['service'] as Map<String, dynamic>),
      option: firstPending['option'] as String,
      day: firstPending['day'] as String,
      time: firstPending['time'] as String,
      note: firstPending['note'] as String?,
      status: firstPending['status'] as String,
    );
  }

  // Convert BookingDetail to Booking (for compatibility with existing code)
  Booking toBooking() {
    return Booking(
      idBooking: id,
      user: User(
        id: 0, // This needs to be populated with actual user data
        email: '', // This needs to be populated with actual user data
        name: '', // This needs to be populated with actual user data
      ),
      service: ServiceBooking(
        id: service.id,
        title: service.title,
        description: service.description,
        option: option,
        day: day,
        time: time,
        status: status,
      ),
    );
  }

  // Convert a list of BookingDetail to a list of Booking
  static List<Booking> convertListToBookings(
      List<BookingDetail> details, UserDetail userDetail) {
    return details
        .map((detail) => Booking(
              idBooking: detail.id,
              user: User(
                id: userDetail.id,
                email: userDetail.email,
                name: userDetail.name,
              ),
              service: ServiceBooking(
                id: detail.service.id,
                title: detail.service.title,
                description: detail.service.description,
                option: detail.option,
                day: detail.day,
                time: detail.time,
                status: detail.status,
              ),
            ))
        .toList();
  }
}

class Service {
  final int id;
  final String title;
  final String description;

  Service({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );
}
