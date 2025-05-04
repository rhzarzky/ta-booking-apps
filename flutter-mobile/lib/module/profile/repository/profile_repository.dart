import 'package:Appointly/module/profile/model/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final Dio _dio;
  final Logger _logger = Logger();

  ProfileRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://192.168.100.18:8000/v1',
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status! < 500,
            connectTimeout: Duration(seconds: 30),
            receiveTimeout: Duration(seconds: 30),
          ),
        );

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

      // If we have an image path, use multipart/form-data
      if (imagePath != null) {
        FormData formData = FormData.fromMap({
          'name': profile.name,
          'email': profile.email,
          'image': await MultipartFile.fromFile(imagePath),
          if (profile.currentPassword != null)
            'current_password': profile.currentPassword,
          if (profile.password != null) 'password': profile.password,
          if (profile.passwordConfirmation != null)
            'password_confirmation': profile.passwordConfirmation,
        });

        final response = await _dio.put(
          '/user/profile',
          data: formData,
        );

        if (response.statusCode == 200) {
          return ProfileModel.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to update profile: ${response.statusMessage}');
        }
      }
      // Otherwise use regular JSON
      else {
        final response = await _dio.put(
          '/user/profile',
          data: profile.toJson(),
        );

        if (response.statusCode == 200) {
          return ProfileModel.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to update profile: ${response.statusMessage}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
