class ApiUrl {
  // static const String baseUrl = 'https://api-appointly.mieso.my.id/v1';
  // static const String baseUrl = 'http://103.160.213.108:8080/v1';
  static const String baseUrl = 'http://192.168.100.18:8000/v1';
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
