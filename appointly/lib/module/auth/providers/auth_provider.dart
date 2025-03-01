import 'package:appointly/module/auth/model/users_model.dart';
import 'package:appointly/module/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  late UsersModel _user;

  UsersModel get user => _user;

  set user(UsersModel user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      UsersModel user = await AuthService().register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      _user = user;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
