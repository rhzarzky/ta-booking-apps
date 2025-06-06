import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class PermissionService {
  static final Logger _logger = Logger();

  // check and request calendar permission
  static Future<bool> requestCalendarPermission() async {
    try {
      // Request both read and write calendar permissions
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.calendar,
        Permission.calendarWriteOnly,
      ].request();

      _logger.i('Calendar permission statuses: $statuses');

      // Check if at least write permission is granted
      final writeStatus =
          statuses[Permission.calendarWriteOnly] ?? PermissionStatus.denied;
      final calendarStatus =
          statuses[Permission.calendar] ?? PermissionStatus.denied;

      final isGranted = writeStatus == PermissionStatus.granted ||
          calendarStatus == PermissionStatus.granted;

      _logger.i('Calendar permission granted: $isGranted');
      return isGranted;
    } catch (e) {
      _logger.e('Error requesting calendar permission: $e');
      return false;
    }
  }

  static Future<bool> hasCalendarPermission() async {
    try {
      final calendarStatus = await Permission.calendar.status;
      final writeStatus = await Permission.calendarWriteOnly.status;

      final hasPermission = calendarStatus == PermissionStatus.granted ||
          writeStatus == PermissionStatus.granted;

      _logger.i(
          'Has calendar permission: $hasPermission (calendar: $calendarStatus, write: $writeStatus)');
      return hasPermission;
    } catch (e) {
      _logger.e('Error checking calendar permission: $e');
      return false;
    }
  }

  // Helper method to open app settings if permission is permanently denied
  static Future<void> openDeviceSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      _logger.e('Error opening app settings: $e');
    }
  }

  // Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final calendarStatus = await Permission.calendar.status;
      final writeStatus = await Permission.calendarWriteOnly.status;

      return calendarStatus == PermissionStatus.permanentlyDenied ||
          writeStatus == PermissionStatus.permanentlyDenied;
    } catch (e) {
      _logger.e('Error checking permanent denial status: $e');
      return false;
    }
  }
}
