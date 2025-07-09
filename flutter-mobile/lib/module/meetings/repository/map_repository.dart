import 'package:Appointly/utils/config.dart';
import 'package:Appointly/module/meetings/model/location_model.dart';
import 'package:dio/dio.dart';

class MapRepository {
  final String token = AppConfig.mapboxAccessToken;
  final Dio _dio = Dio();

  /// Method untuk mendapatkan koordinat dari berbagai sumber data
  Future<Map<String, dynamic>> getLocationCoordinates(
      LocationModel location) async {
    try {
      // Priority 1: Jika sudah ada koordinat, gunakan langsung
      if (location.hasCoordinates) {
        print(
            'Menggunakan koordinat yang sudah ada: ${location.latitude}, ${location.longitude}');

        // Jika ada nama, gunakan nama tersebut, jika tidak, coba reverse geocoding untuk mendapatkan alamat
        String placeName =
            location.name ?? location.address ?? 'Unknown Location';

        // Jika tidak ada nama/address, lakukan reverse geocoding
        if (placeName == 'Unknown Location' || placeName.trim().isEmpty) {
          try {
            final reverseGeocodeResult =
                await _reverseGeocode(location.latitude!, location.longitude!);
            placeName =
                reverseGeocodeResult['place_name'] ?? 'Unknown Location';
          } catch (e) {
            print('Reverse geocoding failed: $e');
            placeName = 'Lat: ${location.latitude}, Lng: ${location.longitude}';
          }
        }

        return {
          'longitude': location.longitude,
          'latitude': location.latitude,
          'place_name': placeName,
        };
      }

      // Priority 2: Jika ada alamat/nama, lakukan geocoding
      if (location.hasAddress) {
        print('Melakukan geocoding untuk alamat: ${location.address}');
        return await getAddressCoordinates(location.address!);
      }

      // Priority 3: Jika hanya ada nama, coba geocoding dengan nama
      if (location.hasName) {
        print('Melakukan geocoding untuk nama: ${location.name}');
        return await getAddressCoordinates(location.name!);
      }

      throw Exception(
          'Tidak ada data lokasi yang valid (koordinat, alamat, atau nama)');
    } catch (e) {
      print('Error getting location coordinates: $e');
      throw Exception('Error saat mendapatkan koordinat lokasi: $e');
    }
  }

  /// Method untuk reverse geocoding (koordinat ke alamat) atau mengkonversi koordinat menjadi nama tempat
  Future<Map<String, dynamic>> _reverseGeocode(
      double latitude, double longitude) async {
    try {
      print('Melakukan reverse geocoding untuk: $longitude, $latitude');

      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json',
        queryParameters: {
          'access_token': token,
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data['features'].isNotEmpty) {
        final feature = response.data['features'][0];
        final placeName = feature['place_name'];

        print('Reverse geocoding berhasil: $placeName');

        return {
          'longitude': longitude,
          'latitude': latitude,
          'place_name': placeName,
        };
      } else {
        throw Exception('Tidak dapat melakukan reverse geocoding');
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      throw Exception('Error saat reverse geocoding: $e');
    }
  }

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
        // hanya mengambil koordinat dari 'center'
        // yang merupakan [longitude, latitude]
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
        //kenapa di bagi 1000? karena distance yang didapat dari API adalah dalam satuan meter
        final distance = route['distance'] / 1000; // convert to km
        // kenapa di bagi 60? karena duration yang didapat dari API adalah dalam satuan detik
        final duration = route['duration'] / 60; // convert to minutes
        // mengambil geometri rute dalam format GeoJSON
        // LineString coordinates untuk polyline
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
