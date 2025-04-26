class BookingDetailResponse {
  final String status;
  final String message;
  final User user;
  final BookingServices services;

  BookingDetailResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.services,
  });

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingDetailResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      services: BookingServices.fromJson(json['services'] as Map<String, dynamic>),
    );
  }
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class BookingServices {
  final List<BookingDetail> pending;

  BookingServices({required this.pending});

  factory BookingServices.fromJson(Map<String, dynamic> json) {
    return BookingServices(
      pending: (json['Pending'] as List<dynamic>)
          .map((e) => BookingDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
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

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'] as int,
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
      option: json['option'] as String,
      day: json['day'] as String,
      time: json['time'] as String,
      note: json['note'] as String?,
      status: json['status'] as String,
    );
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

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}