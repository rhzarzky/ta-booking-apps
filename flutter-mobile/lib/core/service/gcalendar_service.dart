// Google Calendar API
import 'package:googleapis/calendar/v3.dart' as calendar;
// Google Auth
import 'package:googleapis_auth/auth_io.dart';
// Google Sign In
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GoogleCalendarService {
  // permission yg diminta ke user untuk akses calendar
  static const List<String> _scopes = [calendar.CalendarApi.calendarScope];
  final Logger _logger = Logger();
  // inisialisasi GoogleSignIn dengan scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    // Add this for testing unverified apps
    hostedDomain: '', // Empty string allows any domain
  );

  // sign in to get auth client
  // cek apakah user sudah login atau belum
  Future<AuthClient?> _getAuthClient() async {
    try {
      _logger.i('Attempting Google sign-in for calendar access...');

      // Check if user is already signed in
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        // Sign in interactively
        _logger.i('No existing sign-in found, prompting user...');
        // User harus manual pilih akun dan berikan permission dari dialog Google
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        _logger.w('User cancelled Google sign-in');
        return null;
      }

      _logger.i('Google sign-in successful for: ${account.email}');
      // Mengambil authentication credentials dari Google account yang sudah berhasil sign-in.
      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.accessToken == null) {
        _logger.e('Failed to get access token from Google sign-in');
        return null;
      }

      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          // Set expiration time to 1 hour from now
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        // Scopes yang diminta untuk akses calendar
        _scopes,
      );

      return authenticatedClient(http.Client(), credentials);
    } catch (e) {
      _logger.e('Error getting auth client: $e');

      // Add specific handling for verification errors
      if (e.toString().contains('access_denied') ||
          e.toString().contains('verification')) {
        _logger.w(
            'App verification issue detected. This is expected for development.');
        throw Exception(
            'Google app verification required. Pastikan email Anda sudah ditambahkan sebagai test user di Google Cloud Console.');
      }

      return null;
    }
  }

  // add event to gcalendar
  Future<bool> addEventToCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? meetingUrl,
  }) async {
    try {
      _logger.i('Creating calendar event: $title');
// get auth client
      final AuthClient? client = await _getAuthClient();

      if (client == null) {
        throw Exception('Failed to get auth client with google');
      }
// creatate calendar API instance
      final calendar.CalendarApi calendarApi = calendar.CalendarApi(client);

      // create event
      final calendar.Event event = calendar.Event()
      // fungsi (..)-> untuk menginisialisasi properti event
        ..summary = title
        ..description = description
        ..location = location
        ..start = calendar.EventDateTime()
        ..end = calendar.EventDateTime();

      // Set waktu start dan end
      event.start!.dateTime = startTime.toUtc();
      event.start!.timeZone = 'UTC';

      event.end!.dateTime = endTime.toUtc();
      event.end!.timeZone = 'UTC';

      // Tambahkan meeting URL jika ada
      if (meetingUrl != null) {
        event.conferenceData = calendar.ConferenceData()
          ..conferenceSolution = (calendar.ConferenceSolution()
            ..name = 'Google Meet'
            ..iconUri =
                'https://fonts.gstatic.com/s/i/productlogos/meet_2020q4/v6/web-512dp/logo_meet_2020q4_color_2x_web_512dp.png')
          ..entryPoints = [
            calendar.EntryPoint()
              ..entryPointType = 'video'
              ..uri = meetingUrl
          ];
      }

      // Tambahkan reminder
      event.reminders = calendar.EventReminders()
        ..useDefault = false
        ..overrides = [
          calendar.EventReminder()
            ..method = 'popup'
            ..minutes = 30,
          calendar.EventReminder()
            ..method = 'email'
            ..minutes = 60,
        ];

      // Insert event ke calendar
      final insertedEvent = await calendarApi.events.insert(event, 'primary');
      _logger.i('Calendar event created successfully: ${insertedEvent.id}');

      client.close();
      return true;
    } catch (e) {
      _logger.e('Error adding event to calendar: $e');

      // Provide more specific error messages
      if (e.toString().contains('access_denied')) {
        throw Exception(
            'Akses ditolak. Pastikan email Anda sudah ditambahkan sebagai test user di Google Cloud Console.');
      } else if (e.toString().contains('verification')) {
        throw Exception(
            'App belum diverifikasi Google. Ini normal untuk development testing.');
      } else if (e.toString().contains('insufficient')) {
        throw Exception(
            'Permission tidak cukup. Pastikan scope calendar sudah ditambahkan.');
      }

      throw Exception('Gagal membuat calendar event: ${e.toString()}');
    }
  }

  // check if user has logged in to google
  Future<bool> isLoggedIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (e) {
      _logger.e('Error checking login status: $e');
      return false;
    }
  }

  // sign out from google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _logger.i('Successfully signed out from Google');
    } catch (e) {
      _logger.e('Error signing out: $e');
    }
  }
}
