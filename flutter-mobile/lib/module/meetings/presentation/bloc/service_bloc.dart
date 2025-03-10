import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    on<GetServiceEvent>((event, emit) async {
      emit(ServiceLoading());
      try {
        // Cek dan ambil token terlebih dahulu
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // Set token sebelum melakukan request
        if (token != null && token.isNotEmpty) {
          serviceRepository.updateToken(token);
        }
        final result = await serviceRepository.getServices();
        print('Services Loaded: ${result.services}'); // Add this line
        emit(ServiceLoaded(result.services));
      } catch (e) {
        emit(
          ServiceFailure(
            failure: e.toString(),
          ),
        );
      }
    });

    on<UpdateTokenEvent>((event, emit) {
      try {
        // Periksa token sebelum meneruskannya ke repository
        final token = event.token;
        print('Updating token: ${token ?? "NULL TOKEN"}');

        // Hanya update jika token tidak null dan tidak kosong
        if (token != null && token.isNotEmpty) {
          serviceRepository.updateToken(token);
        } else {
          print('Warning: Attempted to update with null or empty token');
        }
      } catch (e) {
        print('Error updating token: ${e.toString()}');
      }
    });
  }
}
