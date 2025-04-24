
class UsersModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String token;

  UsersModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = "",
    this.status = "",
    required this.token,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    
    return UsersModel(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        role: userData['role']?.toString() ?? "",
        status: userData['status']?.toString() ?? "",
        token: json['token']?.toString() ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'token': token,
    };
  }
}
