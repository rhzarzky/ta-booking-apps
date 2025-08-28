class BookingDetailModel {
  final String status;
  final String message;
  final int idBooking;
  final UserDetail user;
  final BookingDetail service;

  BookingDetailModel({
    required this.status,
    required this.message,
    required this.idBooking,
    required this.user,
    required this.service,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      status: json['status'] as String,
      message: json['message'] as String,
      idBooking: json['id_booking'] as int,
      user: UserDetail.fromJson(json['user']),
      service: BookingDetail.fromJson(json['service']),
    );
  }
}

class UserDetail {
  final int id;
  final String name;
  final String email;

  UserDetail({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class BookingDetail {
  final Service service;
  final String option;
  final String date;
  final String time;
  final String? note;
  final String status;

  BookingDetail({
    required this.service,
    required this.option,
    required this.date,
    required this.time,
    this.note,
    required this.status,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      service: Service.fromJson(json),
      option: json['option'] as String? ?? 'Offline',
      date: json['date'] as String? ?? 'Unknown',
      time: (json['time'] as String? ?? '00:00:00').substring(0, 5), //mengubah format waktu dari 'HH:mm:ss' ke 'HH:mm'
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'Pending',
    );
  }
}

class Service {
  final int id;
  final String title;
  final String description;
  final String? location;
  final String? image;

  Service({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    this.image,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id_service'] as int? ?? 0,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description',
      location: json['location'] as String?,
      image: json['image'] as String?,
    );
  }
}
