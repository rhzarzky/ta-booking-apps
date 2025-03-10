import 'package:Appointly/module/auth/model/users_model.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/onboarding/repository/onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ServiceBloc _serviceBloc;

  AuthBloc(this._authRepository, this._serviceBloc) : super(AuthInitial()) {
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
        _serviceBloc.add(UpdateTokenEvent(user.token));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginUser>(
      (event, emit) async {
        emit(AuthLoading());
        try {
          final user = await _authRepository.login(
            email: event.email,
            password: event.password,
          );
          emit(AuthSuccess(user));
          _serviceBloc.add(UpdateTokenEvent(user.token));
        } catch (e) {
          emit(AuthFailure(e.toString()));
        }
      },
    );

    // Di dalam AuthBloc
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final isAuthenticated = await _authRepository.isLoggedIn();

        if (isAuthenticated) {
          final token = await _authRepository.getToken(); // Ambil token
          if (token != null && token.isNotEmpty) {
            _serviceBloc.add(UpdateTokenEvent(token)); // Update ServiceBloc
            emit(AuthAuthenticated());
          } else {
            await _authRepository.logout();
            emit(AuthUnauthenticated());
          }
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutUser>(
      (event, emit) async {
        _authRepository.logout();
        final onboardingRepo = OnboardingRepository();
        await onboardingRepo.completeOnboarding();
        emit(AuthUnauthenticated());
      },
    );
  }
}
