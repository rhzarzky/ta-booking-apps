import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRepository {
  final Dio _dio;

  ServiceRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://192.168.100.18:8000/v1',
            headers: {
              'Content-Type': 'application/json',
            },
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
      print('Authorization header removed because token is null or empty');
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
          print('WARNING: No token available for service request');
        }
      }

      print('Headers dd before request: ${_dio.options.headers}');
      final response = await _dio.get('/service');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return DataService.fromJson(response.data);
      } else {
        print('Service error: ${response.statusMessage}');
        throw Exception('Failed to load services: ${response.statusMessage}');
      }
    } catch (e) {
      print('ServiceRepository error: ${e.toString()}');
      rethrow;
    }
  }
}
