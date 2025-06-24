class LocationModel {
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? address;

  LocationModel({
    this.name,
    this.latitude,
    this.longitude,
    this.address,
  });

  // Check if we have valid coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Check if we have address for geocoding
  bool get hasAddress => address != null && address!.trim().isNotEmpty;

  // Check if we have name
  bool get hasName => name != null && name!.trim().isNotEmpty;

  // Factory constructor from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name']?.toString(),
      latitude: json['latitude'] != null
          ? (json['latitude'] is String
              ? double.tryParse(json['latitude'])
              : (json['latitude'] as num).toDouble())
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] is String
              ? double.tryParse(json['longitude'])
              : (json['longitude'] as num).toDouble())
          : null,
      address: json['address']?.toString() ?? json['location']?.toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'LocationModel(name: $name, lat: $latitude, lng: $longitude, address: $address)';
  }
}
