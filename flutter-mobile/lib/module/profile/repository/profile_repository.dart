import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/profile/model/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final Dio _dio = ApiService.instance;
  final Logger _logger = Logger();

  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<ProfileModel> getProfile() async {
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

      final response = await _dio.get('/user/profile');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load services: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileModel> updateProfile(
      ProfileModel profile, String? imagePath) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }

      FormData formData = FormData.fromMap({
        '_method': 'PUT', // Add this line to override POST to PUT
        if (profile.name != null) 'name': profile.name,
        if (profile.email != null) 'email': profile.email,
        if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
        if (profile.currentPassword != null)
          'current_password': profile.currentPassword,
        if (profile.password != null) 'password': profile.password,
        if (profile.passwordConfirmation != null)
          'password_confirmation': profile.passwordConfirmation,
      });

      final response = await _dio.post(
        // Keep this as POST
        '/user/profile',
        data: formData,
      );

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else if (response.statusCode == 403) {
        throw Exception('The current password is incorrect');
      } else {
        throw Exception(
            'Failed to update profile: ${response.data['message'] ?? response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        _logger.e('Dio error: ${e.response?.data}');
        throw Exception(
            'Server responded with: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}');
      } else {
        _logger.e('Dio error: ${e.message}');
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }
}
