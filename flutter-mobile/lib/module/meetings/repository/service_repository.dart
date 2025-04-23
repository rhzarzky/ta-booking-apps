import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ServiceRepository {
  final Dio _dio;
  final Logger _logger = Logger();

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

  Future<DataService> postService(
    int id, {
    required String time,
    required String day,
    required String note,
    required String option,
  }) async {
    try {
      if (!_dio.options.headers.containsKey('Authorization')) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          updateToken(token);
        }
      }
      final response = await _dio.post('/service/$id/book', data: {
        'time': time,
        'day': day,
        'note': note,
        'option': option,
      });

      if (response.statusCode == 200) {
        return DataService.fromJson(response.data);
      } else {
        throw Exception('Failed to post service: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
