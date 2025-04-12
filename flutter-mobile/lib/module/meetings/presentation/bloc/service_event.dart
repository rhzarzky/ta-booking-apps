part of 'service_bloc.dart';

@immutable
sealed class ServiceEvent {}

class GetServiceEvent extends ServiceEvent {}

class GetServiceIdEvent extends ServiceEvent {
  final int id;

  GetServiceIdEvent({required this.id});
}

class UpdateTokenEvent extends ServiceEvent {
  final String? token;

  UpdateTokenEvent(this.token);
}
