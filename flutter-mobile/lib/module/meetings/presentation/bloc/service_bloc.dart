import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;
  final Logger _logger = Logger();

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    // all service
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
        emit(ServiceLoaded(result.services));
      } catch (e) {
        emit(
          ServiceFailure(
            failure: e.toString(),
          ),
        );
      }
    });

    // service by id
    on<GetServiceIdEvent>((event, emit) async {
      emit(ServiceLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null && token.isNotEmpty) {
          serviceRepository.updateToken(token);
        }

        final result = await serviceRepository.getServiceById(event.id);

        emit(ServiceLoaded(result.services));
      } catch (e) {
        emit(ServiceFailure(failure: e.toString()));
      }
    });

    // update token
    on<UpdateTokenEvent>((event, emit) {
      try {
        // Periksa token sebelum meneruskannya ke repository
        final token = event.token;

        // Hanya update jika token tidak null dan tidak kosong
        if (token != null && token.isNotEmpty) {
          serviceRepository.updateToken(token);
        }
      } catch (e) {
        _logger.e('Error updating token: ${e.toString()}');
      }
    });

    // booking service
    on<BookService>((event, emit) async {
      emit(ServiceLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null && token.isNotEmpty) {
          serviceRepository.updateToken(token);
        }
        final response = await serviceRepository.postServiceWithCalendar(
          event.serviceId,
          time: event.time,
          date: event.date,
          note: event.notes,
          option: event.option,
          // syncToCalendar: true,
        );

        final result = await serviceRepository.getServiceById(event.serviceId);

        // Emit success state with booking ID
        emit(ServiceSucees(result.services.first,
            bookingId: response.bookingId ?? 0));
      } catch (e) {
        emit(ServiceFailure(failure: e.toString()));
      }
    });
  }
}
