part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoaded extends AuthState {}

final class AuthSuccess extends AuthState {
  final UsersModel user;

  AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String failure;

  AuthFailure(this.failure);
}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthForgotPassword extends AuthState {}

class AuthForgotPasswordSuccess extends AuthState {}

class AuthForgotPasswordFailure extends AuthState {
  final String failure;

  AuthForgotPasswordFailure(this.failure);
}

class AuthVerifyOTP extends AuthState {}

class AuthVerifyOTPSuccess extends AuthState {}

class AuthVerifyOTPFailure extends AuthState {
  final String failure;

  AuthVerifyOTPFailure(this.failure);
}

class AuthResetPassword extends AuthState {}

class AuthResetPasswordSuccess extends AuthState {}

class AuthResetPasswordFailure extends AuthState {
  final String failure;

  AuthResetPasswordFailure(this.failure);
}

class AuthResendOTP extends AuthState {}

class AuthResendOTPSuccess extends AuthState {}

class AuthResendOTPFailure extends AuthState {
  final String failure;

  AuthResendOTPFailure(this.failure);
}
