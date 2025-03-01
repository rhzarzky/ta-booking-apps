class UsersModel {
  final int id;
  final String email;
  final String password;
  final String token;

  UsersModel({
    required this.id,
    required this.email,
    required this.password,
    required this.token,
  });

  UsersModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        password = json['password'],
        token = json['token'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'token': token,
    };
  }
}
