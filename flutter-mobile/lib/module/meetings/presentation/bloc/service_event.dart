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

class BookService extends ServiceEvent {
  final int serviceId;
  final String option;
  final String date;
  final String notes;
  final String time;

  BookService({
    required this.serviceId,
    required this.option,
    required this.date,
    required this.notes,
    required this.time,
  });
}
