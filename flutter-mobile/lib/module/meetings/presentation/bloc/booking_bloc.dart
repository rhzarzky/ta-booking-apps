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

        final stats = {
          'approved': approved.length,
          'pending': pending.length,
          'declined': declined.length,
        };

        emit(BookingLoaded(
            approved: approved,
            pending: pending,
            declined: declined,
            stats: stats));
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

        // Make sure we have the full booking lists when viewing a specific booking
        if (state is! BookingLoaded) {
          await _loadAllBookings(emit);
        }

        if (state is BookingLoaded) {
          final currentState = state as BookingLoaded;
          emit(BookingLoaded(
              approved: currentState.approved,
              pending: currentState.pending,
              declined: currentState.declined,
              bookingDetail: bookingDetail,
              stats: currentState.stats));
        } else {
          emit(BookingLoaded(
            approved: [],
            pending: [],
            declined: [],
            bookingDetail: bookingDetail,
            stats: {},
          ));
        }
      } catch (e) {
        _logger.e('Error fetching booking by ID: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });

    // Filter bookings by date range
    on<FilterBookingsByDateRangeEvent>((event, emit) async {
      if (state is! BookingLoaded) {
        await _loadAllBookings(emit);
        return;
      }

      final currentState = state as BookingLoaded;
      final DateTime startDate = event.startDate;
      final DateTime endDate = event.endDate;

      // Filter the bookings by date range
      final filteredApproved =
          _filterBookingsByDateRange(currentState.approved, startDate, endDate);
      final filteredPending =
          _filterBookingsByDateRange(currentState.pending, startDate, endDate);
      final filteredDeclined =
          _filterBookingsByDateRange(currentState.declined, startDate, endDate);

      final stats = {
        'approved': filteredApproved.length,
        'pending': filteredPending.length,
        'declined': filteredDeclined.length,
      };

      emit(BookingLoaded(
        approved: filteredApproved,
        pending: filteredPending,
        declined: filteredDeclined,
        bookingDetail: currentState.bookingDetail,
        stats: stats,
        isFiltered: true,
        filterStartDate: startDate,
        filterEndDate: endDate,
      ));
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

  // Helper method to load all bookings
  Future<void> _loadAllBookings(Emitter<BookingState> emit) async {
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

      final stats = {
        'approved': approved.length,
        'pending': pending.length,
        'declined': declined.length,
      };

      emit(BookingLoaded(
          approved: approved,
          pending: pending,
          declined: declined,
          stats: stats));
    } catch (e) {
      _logger.e('Error fetching bookings: $e');
      emit(BookingFailure(failure: e.toString()));
    }
  }

  // Helper method to filter bookings by date range
  List<Booking> _filterBookingsByDateRange(
      List<Booking> bookings, DateTime startDate, DateTime endDate) {
    return bookings.where((booking) {
      try {
        final bookingDate = DateFormat('yyyy-MM-dd').parse(booking.service.day);
        return bookingDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            bookingDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        _logger.e('Error parsing date: ${booking.service.day}');
        return false;
      }
    }).toList();
  }
}
