import 'package:appointly/module/meetings/model/service_model.dart';
import 'package:dio/dio.dart';

class ServiceRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.5.231:8000/v1',
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status! < 500,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  Future<DataService> getSerivces()async {
    final resonse = await _dio.get('/service');
    return DataService.fromJson(resonse.data);
  }
}
