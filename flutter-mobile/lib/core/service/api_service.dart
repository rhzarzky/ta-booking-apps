import 'package:Appointly/core/secret/api_secret.dart';
import 'package:dio/dio.dart';

class ApiService {
  // menggunakan static karena untuk memastikan hanya ada satu instance Dio yang digunakan di seluruh aplikasi dan hemat memori.
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDioInstance();
    return _instance!;
  }

  static Dio _createDioInstance() {
    return Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        headers: ApiUrl.headers,
        validateStatus: (status) => status! < 500,
        connectTimeout: Duration(seconds: ApiUrl.connectionTimeout),
        receiveTimeout: Duration(seconds: ApiUrl.receiveTimeout),
      ),
    );
  }

// kenapa menggunakan void, karena method ini tidak mengembalikan nilai apapun, hanya melakukan aksi untuk mengatur ulang instance Dio.
  static void resetInstance() {
    _instance = null;
  }
}
