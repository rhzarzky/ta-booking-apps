class SavedServiceModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String location;
  final List<dynamic> option;

  SavedServiceModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.location,
    required this.option,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'location': location,
        'option': option,
      };

  factory SavedServiceModel.fromJson(Map<String, dynamic> json) {
    return SavedServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      location: json['location'],
      option: json['option'],
    );
  }
}
