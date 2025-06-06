import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:Appointly/core/service/gcalendar_service.dart';
import 'package:Appointly/core/service/permission_service.dart';

class ServiceRepository {
  final Dio _dio = ApiService.instance;
  final Logger _logger = Logger();
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<DataService> getServices() async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        } else {
          _logger.w('No token available for service request');
        }
      }

      final response = await _dio.get('/service');

      if (response.statusCode == 200) {
        return DataService.fromJson(response.data);
      } else {
        throw Exception('Failed to load services: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DataService> getServiceById(int id) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      // Pertama, coba dapatkan semua services
      final allServicesResponse = await _dio.get('/service');
      if (allServicesResponse.statusCode == 200) {
        final allServices = DataService.fromJson(allServicesResponse.data);

        // Cari service dengan ID yang sesuai
        final filteredServices =
            allServices.services.where((s) => s.id == id).toList();
        if (filteredServices.isNotEmpty) {
          return DataService(services: filteredServices);
        }
      }

      // Jika endpoint /service/{id} tidak berfungsi dengan baik, kita bisa gunakan cara di atas
      // Tetapi kita masih mencoba endpoint langsung juga
      final response = await _dio.get('/service/$id');

      if (response.statusCode == 200) {
        // Jika API mengembalikan single object (bukan array)
        if (response.data is Map && !response.data.containsKey('services')) {
          // Buat service object dari response dan wrap dalam array
          final service = Service.fromModel(response.data);
          return DataService(services: [service]);
        }

        // Jika response berisi key 'services' seperti biasa
        return DataService.fromJson(response.data);
      } else {
        throw Exception('Failed to load service: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.w('Error in getServiceById: $e');
      rethrow;
    }
  }

  Future<bool> createCalendarEvent({
    required String serviceTitle,
    required String serviceDescription,
    required DateTime bookingDate,
    required String bookingTime,
    required String location,
    String? meetingUrl,
  }) async {
    try {
      _logger.i('Starting calendar event creation...');

      // Check calendar permission first
      _logger.i('Checking calendar permission...');
      final hasPermission = await PermissionService.hasCalendarPermission();
      _logger.i('Has calendar permission: $hasPermission');

      if (!hasPermission) {
        _logger.w('Calendar permission not granted, requesting...');
        final granted = await PermissionService.requestCalendarPermission();
        _logger.i('Permission request result: $granted');

        if (!granted) {
          // Check if permission is permanently denied
          final isPermanentlyDenied =
              await PermissionService.isPermissionPermanentlyDenied();
          if (isPermanentlyDenied) {
            _logger.w('Calendar permission permanently denied');
            throw Exception(
                'Permission calendar ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.');
          } else {
            _logger.w('Calendar permission denied by user');
            throw Exception(
                'Permission calendar diperlukan untuk menambahkan event ke Google Calendar.');
          }
        }
      }

      // Parse booking time to create proper DateTime
      _logger.i('Parsing booking time: $bookingTime');
      final timeComponents = bookingTime.split(':');
      if (timeComponents.length < 2) {
        throw Exception('Invalid time format: $bookingTime');
      }

      final hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);

      // Combine date and time
      final startDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        hour,
        minute,
      );

      // Assume 1 hour appointment duration
      final endDateTime = startDateTime.add(const Duration(hours: 1));

      _logger.i('Creating calendar event: $serviceTitle on $startDateTime');

      // Add event to Google Calendar
      final success = await _calendarService.addEventToCalendar(
        title: 'Appointment: $serviceTitle',
        description: serviceDescription,
        startTime: startDateTime,
        endTime: endDateTime,
        location: location,
        meetingUrl: meetingUrl,
      );

      if (success) {
        _logger.i('Event successfully added to Google Calendar');
      } else {
        _logger.w('Failed to add event to Google Calendar');
      }

      return success;
    } catch (e) {
      _logger.e('Error creating calendar event: $e');
      rethrow; // Re-throw to let the caller handle the specific error message
    }
  }

  // Enhanced postService method with calendar integration
  Future<DataService> postServiceWithCalendar(
    int id, {
    required String time,
    required String date,
    required String note,
    required String option,
    bool syncToCalendar = false,
    Service? serviceDetails,
  }) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      // First, create the booking
      final response = await _dio.post('/service/$id/book', data: {
        'time': time,
        'note': note,
        'date': date,
        'option': option,
      });

      if (response.statusCode == 201) {
        final bookingId = response.data['booking']['id_booking'] as int;

        // If sync to calendar is requested and service details are available
        if (syncToCalendar && serviceDetails != null) {
          try {
            // Parse the date string to DateTime
            final bookingDate = DateTime.parse(date);

            // Determine location based on option
            String location = serviceDetails.location;
            String? meetingUrl;

            if (option.toLowerCase() == 'online') {
              // If it's online, the location might contain meeting URL
              meetingUrl = response.data['booking']['location'];
              location = 'Online Meeting';
            }

            // Create calendar event
            final calendarSuccess = await createCalendarEvent(
              serviceTitle: serviceDetails.title,
              serviceDescription: serviceDetails.description,
              bookingDate: bookingDate,
              bookingTime: time,
              location: location,
              meetingUrl: meetingUrl,
            );

            if (calendarSuccess) {
              _logger.i('Booking and calendar event created successfully');
            } else {
              _logger.w('Booking created but calendar sync failed');
            }
          } catch (calendarError) {
            _logger.e('Calendar sync error: $calendarError');
            // Don't fail the booking if calendar sync fails
          }
        }

        return DataService(services: [], bookingId: bookingId);
      } else {
        throw Exception('Failed to post service: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in postServiceWithCalendar: $e');
      rethrow;
    }
  }

  // Check if user is signed in to Google
  Future<bool> isGoogleSignedIn() async {
    try {
      return await _calendarService.isLoggedIn();
    } catch (e) {
      _logger.e('Error checking Google sign in status: $e');
      return false;
    }
  }

  // Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _calendarService.signOut();
      _logger.i('Signed out from Google successfully');
    } catch (e) {
      _logger.e('Error signing out from Google: $e');
    }
  }
}
