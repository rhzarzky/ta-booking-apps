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

      final response = await _dio.get('/user');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load services: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
