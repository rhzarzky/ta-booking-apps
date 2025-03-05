import 'package:appointly/module/meetings/model/service_model.dart';
import 'package:appointly/module/meetings/repository/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    on<GetServiceEvent>((event, emit) async {
      emit(ServiceLoading());
      try {
        final result = await serviceRepository.getSerivces();
        emit(ServiceLoaded(result.services));
      } catch (e) {
        emit(
          ServiceFailure(
            failure: e.toString(),
          ),
        );
      }
    });
  }
}
