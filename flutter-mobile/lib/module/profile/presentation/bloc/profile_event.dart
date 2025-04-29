part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}


class UpdateTokenEvent extends ProfileEvent {
  final String? token;

  UpdateTokenEvent(this.token);
}
