import 'package:Appointly/utils/config.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class MapRepository {
  final String token = AppConfig.mapboxAccessToken;
  final Dio _dio = Dio();

  ///Method ini digunakan untuk mengkonversi alamat menjadi koordinat (geocoding)

  Future<Map<String, dynamic>> getAddressCoordinates(String address) async {
    try {
      // Pastikan alamat tidak kosong
      if (address.trim().isEmpty) {
        throw Exception('Alamat lokasi kosong');
      }

      // mengenkode alamat agar aman digunakan dalam URL
      final encodedAddress = Uri.encodeComponent(address);

      print('Mencoba geocode alamat: $encodedAddress');

      /// (membatasi hasil hanya 1 lokasi)
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedAddress.json',
        queryParameters: {
          'access_token': token,
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data['features'].isNotEmpty) {
        final feature = response.data['features'][0];
        final coordinates = feature['center'];
        final placeName = feature['place_name'];

        print(
            'Berhasil mendapatkan koordinat: ${coordinates[0]}, ${coordinates[1]}');

        return {
          'longitude': coordinates[0],
          'latitude': coordinates[1],
          'place_name': placeName,
        };
      } else {
        print('Tidak ada hasil geocoding untuk alamat: $address');
        throw Exception('Tidak dapat menemukan lokasi');
      }
    } catch (e) {
      print('Error geocoding: $e');
      throw Exception('Error saat mendapatkan koordinat lokasi: $e');
    }
  }

  /// Method ini digunakan untuk mendapatkan informasi perjalanan antara dua titik koordinat
  /// Menerima 4 parameter: koordinat awal (startLat, startLng) dan koordinat tujuan (endLat, endLng)
  Future<Map<String, dynamic>> getTravelInfo(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      /// annotations: Meminta data distance dan duration
      /// overview: 'full' untuk mendapatkan detail rute lengkap
      /// geometries: 'geojson' untuk format geometri
      final response = await _dio.get(
        'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat',
        queryParameters: {
          'access_token': token,
          'annotations': 'distance,duration',
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        final route = response.data['routes'][0];
        final distance = route['distance'] / 1000; // convert to km
        final duration = route['duration'] / 60; // convert to minutes
        final geometry = route['geometry'];

        return {
          'distance': distance,
          'duration': duration,
          'geometry': geometry,
        };
      } else {
        throw Exception('Tidak dapat menemukan rute');
      }
    } catch (e) {
      throw Exception('Error saat mendapatkan info perjalanan: $e');
    }
  }
}
