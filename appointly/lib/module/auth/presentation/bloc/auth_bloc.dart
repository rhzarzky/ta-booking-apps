import 'package:appointly/module/auth/model/users_model.dart';
import 'package:appointly/module/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
          confirmPassword: event.confirmPassword,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit)async{
      emit(AuthLoading());
      final isAuthenticated = await _authRepository.isLoggedIn();
       if (isAuthenticated) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
