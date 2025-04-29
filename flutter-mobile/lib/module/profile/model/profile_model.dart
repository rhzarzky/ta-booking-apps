class ProfileModel {
  final int id;
  final String name;
  final String status;
  final String email;

  ProfileModel({
    required this.email,
    required this.id,
    required this.name,
    required this.status,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json.containsKey('user') ? json['user'] : json;

    return ProfileModel(
      email: userData['email'],
      id: userData['id'],
      name: userData['name'],
      status: userData['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'email': email,
    };
  }
}
