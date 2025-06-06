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

class ForgotPassword extends AuthEvent {
  final String email;

  ForgotPassword({required this.email});
}

class VerifyOTP extends AuthEvent {
  final String otp;

  VerifyOTP({required this.otp});
}

class ResetPassword extends AuthEvent {
  final String password;
  final String confirmPassword;

  ResetPassword({
    required this.password,
    required this.confirmPassword,
  });
}

class ResendOTP extends AuthEvent {
  final String email;

  ResendOTP({required this.email});
}
