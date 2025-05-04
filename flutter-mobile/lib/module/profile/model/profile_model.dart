class ProfileModel {
  final String name;
  final String email;
  final String? image;

  // Tambahan untuk ubah password
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  ProfileModel({
    required this.name,
    required this.email,
    this.image,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json.containsKey('user') ? json['user'] : json;

    return ProfileModel(
      name: userData['name'],
      email: userData['email'],
      image: userData['image'],
      currentPassword: userData['current_password'],
      password: userData['password'],
      passwordConfirmation: userData['password_confirmation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
