import 'dart:convert';
import 'package:appointly/core/secret/api_secret.dart';
import 'package:appointly/module/auth/model/users_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<UsersModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    var url = '$ApiSecret/register';
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print(response.body);

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body)['data'];
      UsersModel user = UsersModel.fromJson(data['user']);
      //user.token = data['token'];

      return user;
    } else {
      throw Exception('Failed to register');
    }
  }
}
