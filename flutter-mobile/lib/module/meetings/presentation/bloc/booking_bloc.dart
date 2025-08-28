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
    // Handle token update
    on<UpdateTokenEvent>((event, emit) {
      historybookingRepository.updateToken(event.token);
    }); // Get all bookings
    on<GetBookingEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          historybookingRepository.updateToken(token);
        }

        final result = await historybookingRepository.getAllBookings(
            month: event.month, year: event.year);
        final currentUser = await _authRepository
            .getUserData(); // Categorize bookings by status
        final approved = <Booking>[];
        final pending = <Booking>[];
        final declined = <Booking>[];
        final completed = <Booking>[];

        // Process pending bookings
        for (var booking in result.services.pending) {
          // Only include bookings for the current user
          if (currentUser != null && booking.service.id != 0) {
            switch (booking.status.toLowerCase()) {
              case 'approved':
                approved.add(booking);
                break;
              case 'completed':
                completed.add(booking);
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

        // Process approved bookings
        for (var booking in result.services.approved) {
          // jika user sudah login dan booking service id tidak 0
          if (currentUser != null && booking.service.id != 0) {
            // tambah approve ke daftar approved
            approved.add(booking);
          }
        }

        // Process completed bookings - masukkan ke completed list
        for (var booking in result.services.completed) {
          if (currentUser != null && booking.service.id != 0) {
            completed.add(booking);
          }
        }

        // Process declined bookings
        for (var booking in result.services.declined) {
          if (currentUser != null && booking.service.id != 0) {
            declined.add(booking);
          }        }
        final stats = {
          'approved': approved.length,
          'pending': pending.length,
          'declined': declined.length,
          'completed': completed.length,
          // add status total booking
          'total': approved.length + pending.length + declined.length + completed.length,
        };

        emit(BookingLoaded(
            approved: approved,
            pending: pending,
            declined: declined,
            completed: completed,
            stats: stats,
            month: event.month,
            year: event.year));
      } catch (e) {
        _logger.e('Error fetching bookings: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });

    // Get booking by id
    on<BookAppointmentByIdEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null && token.isNotEmpty) {
          historybookingRepository.updateToken(token);
        }

        // Get BookingDetail from repository
        final response = await historybookingRepository
            .getBookingDetailResponse(event.idBooking);

        // Create bookingDetail dari response, disesuaikan dengan model yang baru
        final bookingDetail = BookingDetail(
          service: Service(
            id: response.service.service.id,
            title: response.service.service.title,
            description: response.service.service.description,
            location: response.service.service.location,
            image: response.service.service.image,
          ),
          option: response.service.option,
          date: response.service.date,
          time: response.service.time,
          note: response.service.note,
          status: response.service.status,
        );

        _logger.i(
            'this info Booking detail: ${bookingDetail}'); // Make sure we have the full booking lists when viewing a specific booking
        if (state is! BookingLoaded) {
          await _loadAllBookings(emit);
        } else {
          final currentState = state as BookingLoaded;
          await _loadAllBookings(emit,
              month: currentState.month, year: currentState.year);
        }
        if (state is BookingLoaded) {
          final currentState = state as BookingLoaded;
          emit(BookingLoaded(
            approved: currentState.approved,
            pending: currentState.pending,
            declined: currentState.declined,
            completed: currentState.completed,
            bookingDetail: bookingDetail,
            stats: currentState.stats,
            month: currentState.month,
            year: currentState.year,
          ));
        } else {
          emit(BookingLoaded(
            approved: [],
            pending: [],
            declined: [],
            completed: [],
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
      if (state is BookingLoaded) {
        final currentState = state as BookingLoaded;
        final filteredApproved = _filterBookingsByDateRange(
            currentState.approved, event.startDate, event.endDate);
        final filteredPending = _filterBookingsByDateRange(
            currentState.pending, event.startDate, event.endDate);
        final filteredDeclined = _filterBookingsByDateRange(
            currentState.declined, event.startDate, event.endDate);
        final filteredCompleted = _filterBookingsByDateRange(
            currentState.completed, event.startDate, event.endDate);        final filteredStats = {
          'approved': filteredApproved.length,
          'pending': filteredPending.length,
          'declined': filteredDeclined.length,
          'completed': filteredCompleted.length,
          'total': filteredApproved.length + filteredPending.length + filteredDeclined.length + filteredCompleted.length,
        };
        emit(BookingLoaded(
          approved: filteredApproved,
          pending: filteredPending,
          declined: filteredDeclined,
          completed: filteredCompleted,
          stats: filteredStats,
          isFiltered: true,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
          bookingDetail: currentState.bookingDetail,
          month: currentState.month,
          year: currentState.year,
        ));
      }
    }); // Filter bookings by type
    on<FilterBookAppointmentEvent>((event, emit) async {
      if (state is BookingLoaded) {
        // Load all bookings first with the current month/year
        final currentState = state as BookingLoaded;
        await _loadAllBookings(emit,
            month: currentState.month, year: currentState.year);

        if (event.filterType != null && state is BookingLoaded) {
          final currentState = state as BookingLoaded;

          // For search functionality
          if (event.filterType == 'search' && event.searchQuery != null) {
            final searchQuery = event.searchQuery!.toLowerCase();

            // Search in all booking lists
            final filteredApproved = currentState.approved
                .where((booking) =>
                    booking.service.title.toLowerCase().contains(searchQuery) ||
                    booking.service.description
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.service.location
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.date.toLowerCase().contains(searchQuery) ||
                    booking.time.toLowerCase().contains(searchQuery) ||
                    (booking.note?.toLowerCase().contains(searchQuery) ??
                        false))
                .toList();

            final filteredPending = currentState.pending
                .where((booking) =>
                    booking.service.title.toLowerCase().contains(searchQuery) ||
                    booking.service.description
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.service.location
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.date.toLowerCase().contains(searchQuery) ||
                    booking.time.toLowerCase().contains(searchQuery) ||
                    (booking.note?.toLowerCase().contains(searchQuery) ??
                        false))
                .toList();
            final filteredDeclined = currentState.declined
                .where((booking) =>
                    booking.service.title.toLowerCase().contains(searchQuery) ||
                    booking.service.description
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.service.location
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.date.toLowerCase().contains(searchQuery) ||
                    booking.time.toLowerCase().contains(searchQuery) ||
                    (booking.note?.toLowerCase().contains(searchQuery) ??
                        false))
                .toList();

            final filteredCompleted = currentState.completed
                .where((booking) =>
                    booking.service.title.toLowerCase().contains(searchQuery) ||
                    booking.service.description
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.service.location
                        .toLowerCase()
                        .contains(searchQuery) ||
                    booking.date.toLowerCase().contains(searchQuery) ||
                    booking.time.toLowerCase().contains(searchQuery) ||
                    (booking.note?.toLowerCase().contains(searchQuery) ??
                        false))
                .toList();
            emit(BookingLoaded(
              approved: filteredApproved,
              pending: filteredPending,
              declined: filteredDeclined,
              completed: filteredCompleted,
              stats: currentState.stats,
              bookingDetail: currentState.bookingDetail,
              month: currentState.month,
              year: currentState.year,
            ));
            return;
          }

          // Apply filter based on type
          switch (event.filterType!.toLowerCase()) {
            case 'approved':
              emit(BookingLoaded(
                approved: currentState.approved,
                pending: [],
                declined: [],
                completed: [],
                stats: currentState.stats,
                bookingDetail: currentState.bookingDetail,
                month: currentState.month,
                year: currentState.year,
              ));
              break;
            case 'pending':
              emit(BookingLoaded(
                approved: [],
                pending: currentState.pending,
                declined: [],
                completed: [],
                stats: currentState.stats,
                bookingDetail: currentState.bookingDetail,
                month: currentState.month,
                year: currentState.year,
              ));
              break;
            case 'declined':
              emit(BookingLoaded(
                approved: [],
                pending: [],
                declined: currentState.declined,
                completed: [],
                stats: currentState.stats,
                bookingDetail: currentState.bookingDetail,
                month: currentState.month,
                year: currentState.year,
              ));
              break;
            case 'completed':
              emit(BookingLoaded(
                approved: [],
                pending: [],
                declined: [],
                completed: currentState.completed,
                stats: currentState.stats,
                bookingDetail: currentState.bookingDetail,
                month: currentState.month,
                year: currentState.year,
              ));
              break;
            default:
              // Reset to show all
              emit(BookingLoaded(
                approved: currentState.approved,
                pending: currentState.pending,
                declined: currentState.declined,
                completed: currentState.completed,
                stats: currentState.stats,
                bookingDetail: currentState.bookingDetail,
                month: currentState.month,
                year: currentState.year,
              ));
          }
        }
      }
    });

    // Book appointment
    on<BookAppointmentEvent>((event, emit) async {
      emit(BookingLoading());
      try {
        final currentUser = await _authRepository.getUserData();
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        final booking = Booking(
          idBooking: 0, // This will be assigned by the backend
          service: ServiceBooking(
            id: 0, // This will be assigned by the backend
            title: event.title,
            description: event.description,
            location: event.location,
            image: event.image,
          ),
          option: event.location, // Using location as option
          date: event.date,
          time: event.time,
          note: event.note,
          status: event.status,
        );

        await historybookingRepository.createBooking(currentUser.id, booking);
        add(GetBookingEvent()); // Refresh the booking list
      } catch (e) {
        _logger.e('Error creating booking: $e');
        emit(BookingFailure(failure: e.toString()));
      }
    });
  }
  // Helper method to load all bookings
  Future<void> _loadAllBookings(Emitter<BookingState> emit,
      {int? month, int? year}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        historybookingRepository.updateToken(token);
      }

      final result = await historybookingRepository.getAllBookings(
          month: month, year: year);
      final currentUser =
          await _authRepository.getUserData(); // Categorize bookings by status
      final approved = <Booking>[];
      final pending = <Booking>[];
      final declined = <Booking>[];
      final completed = <Booking>[];

      // Process pending bookings
      for (var booking in result.services.pending) {
        // Only include bookings for the current user
        if (currentUser != null && booking.service.id != 0) {
          switch (booking.status.toLowerCase()) {
            case 'approved':
              approved.add(booking);
              break;
            case 'completed':
              completed.add(booking);
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

      // Process approved bookings
      for (var booking in result.services.approved) {
        if (currentUser != null && booking.service.id != 0) {
          approved.add(booking);
        }
      }

      // Process completed bookings - masukkan ke completed list
      for (var booking in result.services.completed) {
        if (currentUser != null && booking.service.id != 0) {
          completed.add(booking);
        }
      }

      // Process declined bookings
      for (var booking in result.services.declined) {
        if (currentUser != null && booking.service.id != 0) {
          declined.add(booking);
        }
      }      final stats = {
        'approved': approved.length,
        'pending': pending.length,
        'declined': declined.length,
        'completed': completed.length,
        'total': approved.length + pending.length + declined.length + completed.length,
      };
      emit(BookingLoaded(
          approved: approved,
          pending: pending,
          declined: declined,
          completed: completed,
          stats: stats,
          month: month ??
              (state is BookingLoaded ? (state as BookingLoaded).month : null),
          year: year ??
              (state is BookingLoaded ? (state as BookingLoaded).year : null)));
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
        final bookingDate = DateFormat('yyyy-MM-dd').parse(booking.date);
        return bookingDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            bookingDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        _logger.e('Error parsing date: ${booking.date}');
        return false;
      }
    }).toList();
  }
}
