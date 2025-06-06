import 'dart:convert';

import 'package:Appointly/core/service/api_service.dart';
import 'package:Appointly/module/auth/model/users_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final Logger _logger = Logger();
  final Dio _dio = ApiService.instance;

  // Register user
  Future<UsersModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      if (res.statusCode == 201) {
        UsersModel user = UsersModel.fromJson(res.data);
        await _saveToken(user.token);
        await saveUserData(user);
        return user;
      } else {
        String errorMessage = 'Registration failed';
        if (res.data is Map && res.data.containsKey('message')) {
          errorMessage = res.data['message'];
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server took too long to respond. Please try again.');
      } else if (e.response != null && e.response!.data is Map) {
        if (e.response!.data.containsKey('message')) {
          throw Exception(e.response!.data['message']);
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Login user
  Future<UsersModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200) {
        UsersModel user = UsersModel.fromJson(res.data);
        await _saveToken(user.token);
        await saveUserData(user);
        return user;
      } else {
        throw Exception(res.data['message']);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server took too long to respond. Please try again.');
      } else if (e.response != null && e.response!.data is Map) {
        if (e.response!.data.containsKey('message')) {
          throw Exception(e.response!.data['message']);
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
  }

  // Save token
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save user data
  Future<void> saveUserData(UsersModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = {
      'user': {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'status': user.status,
      },
      'token': user.token,
    };
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Get user data
  Future<UsersModel?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(userData);
        _logger.d(
            "Retrieved user data: $jsonData"); // Tambahkan log untuk debugging
        return UsersModel.fromJson(jsonData);
      } catch (e) {
        _logger.e("Error parsing user data: $e"); // Log error
        await prefs.remove('user_data');
        return null;
      }
    }
    return null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      final res = await _dio.post('/forgot-password', data: {'email': email});
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      _logger.e('Error in forgotPassword: $e');
      throw Exception('Failed to send reset password email: ${e.toString()}');
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      final res = await _dio.post('/verify-otp', data: {'otp': otp});
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      _logger.e('Error in verifyOTP: $e');
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String password, String confirmPassword) async {
    try {
      final res = await _dio.post('/reset-password', data: {
        'password': password,
        'password_confirmation': confirmPassword,
      });
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      _logger.e('Error in resetPassword: $e');
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      final res = await _dio.post('/resend-otp', data: {'email': email});
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      _logger.e('Error in resendOTP: $e');
      throw Exception('Failed to resend OTP: ${e.toString()}');
    }
  }
}
