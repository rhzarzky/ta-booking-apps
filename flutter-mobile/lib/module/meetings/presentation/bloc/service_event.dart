part of 'service_bloc.dart';

@immutable
sealed class ServiceEvent {}

class GetServiceEvent extends ServiceEvent {}

class UpdateTokenEvent extends ServiceEvent {
  final String? token;

  UpdateTokenEvent(this.token);
}
