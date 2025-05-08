part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileModel profile;
  final String? imagePath; 
  UpdateProfileEvent({
    required this.profile,
    this.imagePath,
  });

  List<Object> get props => [profile, imagePath ?? ''];
}

class UpdateTokenEvent extends ProfileEvent {
  final String? token;

  UpdateTokenEvent(this.token);
}
