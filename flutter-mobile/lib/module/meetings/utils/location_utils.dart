// Utility class untuk membantu konversi data lokasi
import 'package:Appointly/module/meetings/model/location_model.dart';

class LocationUtils {
  /// Contoh penggunaan untuk membuat LocationModel dari berbagai sumber data

  // 1. Dari koordinat langsung
  static LocationModel fromCoordinates({
    required double latitude,
    required double longitude,
    String? name,
    String? address,
  }) {
    return LocationModel(
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  // 2. Dari alamat saja
  static LocationModel fromAddress(String address, {String? name}) {
    return LocationModel(
      name: name,
      address: address,
    );
  }

  // 3. Dari nama tempat saja
  static LocationModel fromName(String name) {
    return LocationModel(
      name: name,
    );
  }

  // 4. Dari JSON response API
  static LocationModel fromJson(Map<String, dynamic> json) {
    return LocationModel.fromJson(json);
  }

  // 5. Dari service model (sesuaikan dengan struktur service Anda)
  static LocationModel fromService(dynamic service) {
    // Contoh asumsi struktur service:
    // service.location (String alamat)
    // service.title (String nama)
    // service.latitude (double, opsional)
    // service.longitude (double, opsional)

    try {
      double? lat;
      double? lng;

      // Coba ekstrak koordinat jika ada (sesuaikan dengan model service Anda)
      if (service.toString().contains('latitude')) {
        // lat = service.latitude; // Uncomment jika service memiliki field latitude
      }
      if (service.toString().contains('longitude')) {
        // lng = service.longitude; // Uncomment jika service memiliki field longitude
      }

      return LocationModel(
        name: service.title ?? service.name,
        latitude: lat,
        longitude: lng,
        address: service.location,
      );
    } catch (e) {
      // Fallback ke alamat saja
      return LocationModel(
        name: service.title ?? service.name,
        address: service.location,
      );
    }
  }

  /// Contoh data untuk testing
  static List<LocationModel> getExampleLocations() {
    return [
      // 1. Lokasi dengan koordinat lengkap
      LocationModel(
        name: "Surabaya City Center",
        latitude: -7.2575,
        longitude: 112.7521,
        address: "Jl. Tunjungan, Surabaya, Jawa Timur",
      ),

      // 2. Lokasi hanya dengan alamat
      LocationModel(
        address: "Universitas Airlangga, Surabaya",
      ),

      // 3. Lokasi hanya dengan nama
      LocationModel(
        name: "Taman Bungkul",
      ),

      // 4. Lokasi dengan alamat dan nama
      LocationModel(
        name: "Mall Tunjungan Plaza",
        address: "Jl. Embong Malang No.15-31, Surabaya",
      ),
    ];
  }
}

/// Contoh cara menggunakan:
/*
// 1. Menggunakan koordinat langsung
final location1 = LocationUtils.fromCoordinates(
  latitude: -7.2575,
  longitude: 112.7521,
  name: "Kantor Saya",
  address: "Jl. Contoh No. 123",
);

// 2. Menggunakan alamat saja
final location2 = LocationUtils.fromAddress(
  "Universitas Airlangga, Surabaya",
  name: "Kampus UNAIR",
);

// 3. Menggunakan nama saja
final location3 = LocationUtils.fromName("Taman Bungkul");

// 4. Dari data service
final location4 = LocationUtils.fromService(yourServiceObject);

// 5. Dari JSON API
final location5 = LocationUtils.fromJson({
  'name': 'Mall Tunjungan Plaza',
  'latitude': -7.2575,
  'longitude': 112.7521,
  'address': 'Jl. Embong Malang No.15-31, Surabaya',
});

// Kemudian gunakan di MapBloc:
_mapBloc.add(LoadMapWithLocationEvent(location1));
*/
