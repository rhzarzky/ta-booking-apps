class BookingResponse {
  final String status;
  final String message;
  final Bookings bookings;

  BookingResponse({
    required this.status,
    required this.message,
    required this.bookings,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) =>
      BookingResponse(
        status: json['status'] as String,
        message: json['message'] as String,
        bookings: Bookings.fromJson(json['bookings'] as Map<String, dynamic>),
      );
}

class Bookings {
  final List<Booking> pending;

  Bookings({
    required this.pending,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) => Bookings(
        pending: (json['Pending'] as List)
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Booking {
  final int idBooking;
  final User user;
  final ServiceBooking service;

  Booking({
    required this.idBooking,
    required this.user,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        idBooking: json['id_booking'] as int,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        service:
            ServiceBooking.fromJson(json['service'] as Map<String, dynamic>),
      );
}

class User {
  final int id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
      );
}

class ServiceBooking {
  final int id;
  final String title;
  final String description;
  final String option;
  final String day;
  final String time;
  final String status;

  ServiceBooking({
    required this.id,
    required this.title,
    required this.description,
    required this.option,
    required this.day,
    required this.time,
    required this.status,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) => ServiceBooking(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        option: json['option'] as String,
        day: json['day'] as String,
        time: json['time'] as String,
        status: json['status'] as String,
      );
}
