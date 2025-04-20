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

List<DateTime> generateDateRange({
  required String startDate,
  required String endDate,
  required List<String> activeDays,
}) {
  final start = DateTime.parse(startDate);
  final end = DateTime.parse(endDate);
  List<DateTime> selectedDates = [];

  for (DateTime date = start;
      date.isBefore(end.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))) {
    final weekdayName = _getWeekdayName(date.weekday);
    if (activeDays.contains(weekdayName)) {
      selectedDates.add(date);
    }
  }

  return selectedDates;
}

String _getWeekdayName(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return days[weekday - 1];
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
  final List<String> time;
  final List<Map<String, String>> dates; 

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
    required this.time,
    required this.dates, 
  });

  factory Service.fromModel(Map<String, dynamic> json) {
    List<String> parseOption() {
      if (json['option'] is List) {
        final options =
            List<String>.from(json['option'].map((item) => item.toString()));
        // Validate that options only contain "Online" or "Offline"
        return options
            .where((option) => option == 'Online' || option == 'Offline')
            .toList();
      } else if (json['option'] is String) {
        final option = json['option'].toString();
        return option == 'Online' || option == 'Offline' ? [option] : [];
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

    // Menangani time yang bisa berupa string atau list
    List<String> parseTime() {
      if (json['time'] is List) {
        return List<String>.from(json['time'].map((item) => item.toString()));
      } else if (json['time'] is String) {
        return [json['time']];
      }
      return [];
    }

    List<Map<String, String>> parseDates() {
      if (json['date'] is List) {
        return List<Map<String, String>>.from(json['date']
            .map((date) {
              // Validate date format and structure
              try {
                final dateStr = date['date']?.toString();
                final dayStr = date['day']?.toString();

                if (dateStr != null && dayStr != null) {
                  // Validate date format
                  DateTime.parse(dateStr);
                  return {
                    'date': dateStr,
                    'day': dayStr,
                  };
                }
              } catch (e) {
                print('Error parsing date entry: $e');
              }
              return null;
            })
            .where((date) => date != null)
            .cast<Map<String, String>>());
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
      time: parseTime(),
      dates: parseDates(),
    );
  }
}
