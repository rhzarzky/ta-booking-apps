import 'package:Appointly/module/meetings/presentation/bloc/map_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/map_state.dart';
import 'package:Appointly/module/meetings/repository/map_repository.dart';
import 'package:Appointly/module/meetings/model/location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:flutter/foundation.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository _mapRepository;
  mapbox.Point? _destinationPoint;
  mapbox.Point? _currentLocationPoint;

  MapBloc({required MapRepository mapRepository})
      : _mapRepository = mapRepository,
        super(MapInitial()) {
    on<LoadMapEvent>(_onLoadMap);
    on<LoadMapWithLocationEvent>(_onLoadMapWithLocation);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<CalculateRouteEvent>(_onCalculateRoute);
  }

  Future<void> _onLoadMapWithLocation(
    LoadMapWithLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      debugPrint('[MapBloc] Memproses lokasi: ${event.location}');

      final locationData =
          await _mapRepository.getLocationCoordinates(event.location);

      debugPrint(
          '[MapBloc] Koordinat diterima: ${locationData['longitude']}, ${locationData['latitude']}');

      final point = mapbox.Point(
        coordinates: mapbox.Position(
          locationData['longitude'],
          locationData['latitude'],
        ),
      );

      _destinationPoint = point;

      debugPrint('[MapBloc] Emitting MapLoaded state');
      emit(MapLoaded(
        destinationCoordinates: point,
        destinationName: locationData['place_name'],
      ));
    } catch (e) {
      debugPrint('[MapBloc] Error saat memuat peta dengan location model: $e');
      emit(MapError(message: e.toString()));
    }
  }

  Future<void> _onLoadMap(
    LoadMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      debugPrint(
          '[MapBloc] Mendapatkan koordinat untuk alamat: ${event.locationAddress}');

      // Convert string address to LocationModel for backward compatibility
      final locationModel = LocationModel(address: event.locationAddress);
      final locationData =
          await _mapRepository.getLocationCoordinates(locationModel);

      debugPrint(
          '[MapBloc] Koordinat diterima: ${locationData['longitude']}, ${locationData['latitude']}');

      final point = mapbox.Point(
        coordinates: mapbox.Position(
          locationData['longitude'],
          locationData['latitude'],
        ),
      );

      _destinationPoint = point;

      debugPrint('[MapBloc] Emitting MapLoaded state');
      emit(MapLoaded(
        destinationCoordinates: point,
        destinationName: locationData['place_name'],
      ));
    } catch (e) {
      debugPrint('[MapBloc] Error saat memuat peta: $e');
      emit(MapError(message: e.toString()));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      // Request location permission
      debugPrint('[MapBloc] Memeriksa izin lokasi');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[MapBloc] Izin lokasi ditolak, meminta izin');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[MapBloc] Izin lokasi masih ditolak');
          emit(
            MapError(message: 'Izin lokasi ditolak'),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[MapBloc] Izin lokasi ditolak permanen');
        emit(
          MapError(
              message:
                  'Izin lokasi ditolak permanen, harap aktifkan di pengaturan'),
        );
        return;
      }

      // Get current position
      debugPrint('[MapBloc] Mendapatkan posisi saat ini');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      debugPrint(
          '[MapBloc] Posisi saat ini: ${position.longitude}, ${position.latitude}');
      final point = mapbox.Point(
        coordinates: mapbox.Position(position.longitude, position.latitude),
      );

      _currentLocationPoint = point;

      debugPrint('[MapBloc] Emitting CurrentLocationLoaded state');
      emit(CurrentLocationLoaded(currentLocation: point));

      // Jika destinasi sudah ada, otomatis hitung rute
      if (_destinationPoint != null) {
        debugPrint('[MapBloc] Destinasi sudah ada, menghitung rute otomatis');
        add(CalculateRouteEvent(_destinationPoint!));
      }
    } catch (e) {
      debugPrint('[MapBloc] Error saat mendapatkan lokasi saat ini: $e');
      emit(MapError(message: 'Gagal mendapatkan lokasi saat ini: $e'));
    }
  }

  Future<void> _onCalculateRoute(
    CalculateRouteEvent event,
    Emitter<MapState> emit,
  ) async {
    debugPrint('[MapBloc] Mulai menghitung rute');

    // Jangan emit MapLoading di sini, bisa membuat UI berkedip dan menghilangkan marker

    try {
      // Pastikan kita memiliki lokasi saat ini
      if (_currentLocationPoint == null) {
        debugPrint(
            '[MapBloc] Lokasi saat ini tidak tersedia, mencoba mendapatkan lokasi');
        // Coba dapatkan lokasi saat ini
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );

        _currentLocationPoint = mapbox.Point(
          coordinates: mapbox.Position(position.longitude, position.latitude),
        );
      }

      final currentLat = _currentLocationPoint!.coordinates.lat;
      final currentLng = _currentLocationPoint!.coordinates.lng;

      final destinationLat = event.destination.coordinates.lat;
      final destinationLng = event.destination.coordinates.lng;

      debugPrint(
          '[MapBloc] Menghitung rute dari ($currentLng, $currentLat) ke ($destinationLng, $destinationLat)');

      final routeInfo = await _mapRepository.getTravelInfo(
        currentLat.toDouble(),
        currentLng.toDouble(),
        destinationLat.toDouble(),
        destinationLng.toDouble(),
      );

      debugPrint(
          '[MapBloc] Info rute diterima: jarak=${routeInfo['distance']} km, waktu=${routeInfo['duration']} menit');

      final lineCoordinates = <mapbox.Position>[];
      final geometryCoordinates =
          (routeInfo['geometry']['coordinates'] as List<dynamic>);

      for (var coord in geometryCoordinates) {
        lineCoordinates.add(
          mapbox.Position(
            (coord[0] as num).toDouble(),
            (coord[1] as num).toDouble(),
          ),
        );
      }

      final lineString = mapbox.LineString(coordinates: lineCoordinates);

      debugPrint('[MapBloc] Emitting RouteCalculated state');
      emit(RouteCalculated(
        distance: routeInfo['distance'],
        duration: routeInfo['duration'],
        routeGeometry: lineString,
      ));
    } catch (e) {
      debugPrint('[MapBloc] Error saat menghitung rute: $e');
      emit(MapError(message: 'Gagal menghitung rute: $e'));
    }
  }
}
