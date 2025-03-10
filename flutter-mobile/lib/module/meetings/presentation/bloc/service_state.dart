part of 'service_bloc.dart';

@immutable
sealed class ServiceState {}

final class ServiceInitial extends ServiceState {}

final class ServiceLoaded extends ServiceState {
  final List<Service> services;

  ServiceLoaded(this.services);
}

final class ServiceLoading extends ServiceState {}

final class ServiceSuccess extends ServiceState {}

final class ServiceFailure extends ServiceState {
  final String failure;

  ServiceFailure({required this.failure});
}
