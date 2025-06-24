class BookingModel {
  final String status;
  final String message;
  final User user;
  final Bookings services;

  BookingModel({
    required this.status,
    required this.message,
    required this.user,
    required this.services,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        status: json['status'],
        message: json['message'],
        user: User.fromJson(json['user']),
        services: Bookings.fromJson(json['services']),
      );
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id_user'],
        name: json['name'],
        email: json['email'],
      );
}

class Bookings {
  final List<Booking> pending;
  final List<Booking> approved;
  final List<Booking> declined;
  final List<Booking> completed;

  Bookings({
    required this.pending,
    required this.approved,
    required this.declined,
    required this.completed,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) => Bookings(
        pending: (json['Pending'] as List<dynamic>?)
                ?.map((e) => Booking.fromJson(e))
                .toList() ??
            [],
        approved: (json['Approved'] as List<dynamic>?)
                ?.map((e) => Booking.fromJson(e))
                .toList() ??
            [],
        declined: (json['Declined'] as List<dynamic>?)
                ?.map((e) => Booking.fromJson(e))
                .toList() ??
            [],
        completed: (json['Completed'] as List<dynamic>?)
                ?.map((e) => Booking.fromJson(e))
                .toList() ??
            [],
      );
}

class Booking {
  final int idBooking;
  final ServiceBooking service;
  final String option;
  final String date;
  final String time;
  final String? note;
  final String status;

  Booking({
    required this.idBooking,
    required this.service,
    required this.option,
    required this.date,
    required this.time,
    required this.note,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        idBooking: json['id_booking'],
        service: ServiceBooking.fromJson(json['service']),
        option: json['option'],
        date: json['date'],
        time: json['time'],
        note: json['note'],
        status: json['status'],
      );
}

class ServiceBooking {
  final int id;
  final String? image;
  final String title;
  final String description;
  final String location;

  ServiceBooking({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.location,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) => ServiceBooking(
        id: json['id_service'],
        image: json['image'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
      );
}
