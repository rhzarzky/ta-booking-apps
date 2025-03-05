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

  factory Service.fromModel(Map<String, dynamic> json) => Service(
        id: json['id'],
        image: json['image'],
        title: json['title'],
        description: json['description'],
        option: json['option'],
        days: json['days'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        notes: json['notes'],
      );
}
