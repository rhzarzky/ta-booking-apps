import 'package:appointly/module/auth/model/users_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.5.231:8000/v1', 
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status! < 500,
      connectTimeout: Duration(seconds: 30), 
      receiveTimeout: Duration(seconds: 30), 
    ),
  );

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
        await _saveToken(res.data['token']);
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
        throw Exception('Connection timeout. Please check your internet connection.');
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
        await _saveToken(res.data['token']);
        return user;
      } else {
        throw Exception(res.data['message']);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
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
  }

  // Save token
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}