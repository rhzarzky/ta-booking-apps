part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class LoginUser extends AuthEvent {
  final String email;
  final String password;

  LoginUser({
    required this.email,
    required this.password,
  });
}

class LogoutUser extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
