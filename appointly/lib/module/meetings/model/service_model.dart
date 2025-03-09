class DataService {
  final List<Service> services;

  DataService({required this.services});

  factory DataService.fromJson(Map<String, dynamic> json) => DataService(
        services: json['services'] != null
            ? List.from(
                json['services']
                    .map(
                      (service) => Service.fromModel(service),
                    )
                    .toList(),
              )
            : [],
      );
}

class Service {
  final int id;
  final String image;
  final String title;
  final String description;
  final List<String> option;
  final List<String> days;
  final String startDate;
  final String endDate;
  final String? notes;

  Service({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.option,
    required this.days,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  factory Service.fromModel(Map<String, dynamic> json) {
    // Menangani option yang bisa berupa string atau list
    List<String> parseOption() {
      if (json['option'] is List) {
        return List<String>.from(json['option'].map((item) => item.toString()));
      } else if (json['option'] is String) {
        return [json['option']];
      }
      return [];
    }

    // Menangani days yang bisa berupa string atau list
    List<String> parseDays() {
      if (json['days'] is List) {
        return List<String>.from(json['days'].map((item) => item.toString()));
      } else if (json['days'] is String) {
        return [json['days']];
      }
      return [];
    }

    return Service(
      id: json['id'] ?? 0,
      image: json['image']?.toString() ?? "",
      title: json['title']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      option: parseOption(),
      days: parseDays(),
      startDate: json['start_date']?.toString() ?? "",
      endDate: json['end_date']?.toString() ?? "",
      notes: json['notes']?.toString(),
    );
  }
}
