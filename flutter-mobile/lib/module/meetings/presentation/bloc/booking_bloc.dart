import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart';
import 'package:Appointly/module/meetings/repository/historyBooking_repository.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:intl/intl.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final HistorybookingRepository historybookingRepository;
  final Logger _logger = Logger();
  final AuthRepository _authRepository = AuthRepository();

  BookingBloc({required this.historybookingRepository})
      : super(BookingInitial()) {
    // get all booking
    on<GetBookingEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          historybookingRepository.updateToken(token);
        }

        final result = await historybookingRepository.getAllBookings();
        final currentUser = await _authRepository.getUserData();

        // Categorize bookings by status and filter by current user
        final approved = <Booking>[];
        final pending = <Booking>[];
        final declined = <Booking>[];

        for (var booking in result.bookings.pending) {
          // Only include bookings for the current user
          if (currentUser != null && booking.user.id == currentUser.id) {
            switch (booking.service.status.toLowerCase()) {
              case 'approved':
                approved.add(booking);
                break;
              case 'pending':
                pending.add(booking);
                break;
              case 'declined':
                declined.add(booking);
                break;
            }
          }
        }

        emit(BookingLoaded(
          approved: approved,
          pending: pending,
          declined: declined,
        ));
      } catch (e) {
        _logger.e('Error fetching bookings: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });

    // get booking by id
    on<BookAppointmentByIdEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          historybookingRepository.updateToken(token);
        }

        final currentUser = await _authRepository.getUserData();
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        final bookingDetail =
            await historybookingRepository.getBookingById(event.idBooking);

        if (state is BookingLoaded) {
          final currentState = state as BookingLoaded;
          emit(BookingLoaded(
              approved: currentState.approved,
              pending: currentState.pending,
              declined: currentState.declined,
              bookingDetail: bookingDetail));
        } else {
          emit(BookingLoaded(
            approved: [],
            pending: [],
            declined: [],
            bookingDetail: bookingDetail,
          ));
        }
      } catch (e) {
        _logger.e('Error fetching booking by ID: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });

    // book appointment
    on<BookAppointmentEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final currentUser = await _authRepository.getUserData();
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        final booking = Booking(
          idBooking: 0, // This will be assigned by the backend
          user: User(
            id: currentUser.id,
            email: currentUser.email,
            name: currentUser.name,
          ),
          service: ServiceBooking(
            id: 0, // This will be assigned by the backend
            title: event.title,
            description: event.description,
            option: event.location,
            day: event.date,
            time: event.time,
            status: event.status,
          ),
        );

        await historybookingRepository.createBooking(booking);
        add(GetBookingEvent()); // Refresh the list after booking
      } catch (e) {
        _logger.e('Error creating booking: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });
  }
}
