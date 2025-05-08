class ProfileModel {
  final String? name;
  final String? email;
  final String? image;

  // Tambahan untuk ubah password
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  ProfileModel({
    this.name,
    this.email,
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
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (image != null) data['image'] = image;
    if (currentPassword != null) data['current_password'] = currentPassword;
    if (password != null) data['password'] = password;
    if (passwordConfirmation != null) {
      data['password_confirmation'] = passwordConfirmation;
    }
    return data;
  }
}
