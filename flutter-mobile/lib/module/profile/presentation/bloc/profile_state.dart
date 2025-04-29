part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  ProfileLoaded(this.profile);
}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final ProfileModel profile;

  ProfileSuccess(this.profile);
}

final class ProfileError extends ProfileState {
  final String failure;

  ProfileError({required this.failure});
}
