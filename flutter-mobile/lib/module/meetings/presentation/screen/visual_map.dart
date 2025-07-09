import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/map_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/map_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/map_state.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/model/location_model.dart';
import 'package:Appointly/module/meetings/repository/map_repository.dart';
import 'package:Appointly/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class VisualMap extends StatefulWidget {
  final BookingModel booking;

  const VisualMap({Key? key, required this.booking}) : super(key: key);

  @override
  State<VisualMap> createState() => _VisualMapState();
}

class _VisualMapState extends State<VisualMap> {
  mapbox.MapboxMap? _mapboxMap;
  final _mapRepository = MapRepository();
  // kenapa menggunakan late karena kita akan menginisialisasi MapBloc di initState
  // dan tidak ingin null safety error, karena MapBloc akan digunakan di listener
  late MapBloc _mapBloc;
  double? _distance;
  double? _duration;
  bool _markerAdded = false;
  bool _currentMarkerAdded = false;

  mapbox.PointAnnotationManager? _destinationAnnotationManager;
  mapbox.PointAnnotationManager? _currentLocationAnnotationManager;

  @override
  void initState() {
    super.initState();
    _mapBloc = MapBloc(mapRepository: _mapRepository);

    // Set Mapbox access token
    if (AppConfig.mapboxAccessToken != null &&
        AppConfig.mapboxAccessToken.isNotEmpty) {
      mapbox.MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
      debugPrint('Mapbox access token set successfully.');
    } else {
      debugPrint('Mapbox access token is not set or empty.');
    } // Tunggu sejenak untuk memastikan widget telah dibangun sepenuhnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.booking.services.approved.isNotEmpty &&
          widget.booking.services.approved[0].option == 'Offline') {
        // Ekstrak data lokasi dengan berbagai format yang didukung
        final locationModel = _extractLocationFromService();

        debugPrint('LocationModel yang diekstrak: $locationModel');

        // Validasi apakah ada data lokasi yang valid
        if (locationModel.hasCoordinates ||
            locationModel.hasAddress ||
            locationModel.hasName) {
          _mapBloc.add(LoadMapWithLocationEvent(locationModel));
          debugPrint(
              'LoadMapWithLocationEvent triggered with locationModel: $locationModel');
        } else {
          debugPrint('Tidak ada data lokasi yang valid');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data lokasi tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        debugPrint(
            'Tidak ada layanan offline yang ditemukan atau layanan yang disetujui kosong');
      }
    });
  }

  @override
  void dispose() {
    // Clear annotation managers
    _destinationAnnotationManager = null;
    _currentLocationAnnotationManager = null;

    // Bersihkan semua resource Mapbox
    if (_mapboxMap != null) {
      _removeExistingLayers(); // Hapus layer dan source
      _mapboxMap = null; // Hapus referensi ke mapbox map
    }

    // Tutup bloc
    _mapBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Meeting'),
        elevation: 0,
      ),
      body: BlocProvider.value(
        value: _mapBloc,
        child: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {
            debugPrint('Current state: ${state.runtimeType}');
            if (state is MapLoaded) {
              debugPrint(
                  'Map loaded with coordinates: ${state.destinationCoordinates.coordinates.lng}, ${state.destinationCoordinates.coordinates.lat}');
              // When destination location is loaded, get our current location
              _mapBloc.add(GetCurrentLocationEvent());

              // If map is already created, add marker now
              if (_mapboxMap != null && !_markerAdded) {
                _addDestinationMarker(state.destinationCoordinates);
                _markerAdded = true;
              }
            } else if (state is CurrentLocationLoaded) {
              debugPrint(
                  'Current location loaded: ${state.currentLocation.coordinates.lng}, ${state.currentLocation.coordinates.lat}');

              // Tambahkan marker lokasi saat ini
              if (_mapboxMap != null && !_currentMarkerAdded) {
                _addCurrentLocationMarker(state.currentLocation);
                _currentMarkerAdded = true;
              }

              // When our location is obtained, calculate the route
              if (_mapBloc.state is MapLoaded) {
                final lastState = _mapBloc.state as MapLoaded;
                debugPrint(
                    'Calculating route to: ${lastState.destinationCoordinates.coordinates.lng}, ${lastState.destinationCoordinates.coordinates.lat}');
                // Trigger route calculation to the destination
                _mapBloc
                    .add(CalculateRouteEvent(lastState.destinationCoordinates));
              }
            } else if (state is RouteCalculated) {
              debugPrint(
                  'Route calculated: Distance: ${state.distance}, Duration: ${state.duration}');
              // Save distance and duration
              setState(() {
                _distance = state.distance;
                _duration = state.duration;
              });

              // Draw route on map
              _drawRoute(state.routeGeometry);
            } else if (state is MapError) {
              debugPrint('Map error: ${state.message}');
              // Tampilkan error ke user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Map container
                      _buildMapView(),

                      // Loading indicator
                      if (state is MapLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),

                      // Error message
                      if (state is MapError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Terjadi error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),

                      // Debug info overlay (sementara untuk debugging)
                      if (state is MapLoaded)
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lokasi: ${state.destinationName}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      // Tombol untuk lokasi saat ini
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.my_location,
                              color: ColorPallete.primaryColor),
                          onPressed: () {
                            setState(() {
                              _currentMarkerAdded = false;
                            });
                            _mapBloc.add(GetCurrentLocationEvent());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Memperbarui lokasi saat ini...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance and time info - selalu tampilkan container, isi dengan loading jika belum ada data
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _locationDetailCard(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoCard(
                              icon: Icons.route,
                              title: 'Jarak',
                              value: _distance != null
                                  ? '${_distance!.toStringAsFixed(1)} km'
                                  : 'Menghitung...',
                              isLoading: _distance == null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _infoCard(
                              icon: Icons.timer,
                              title: 'Waktu Tempuh',
                              value: _duration != null
                                  ? '${_duration!.toStringAsFixed(0)} menit'
                                  : 'Menghitung...',
                              isLoading: _duration == null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentMarkerAdded = false;
                            });
                            _mapBloc.add(GetCurrentLocationEvent());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Memperbarui rute...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('Perbarui Rute'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ColorPallete.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _locationDetailCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Lokasi Meeting',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorPallete.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.booking.services.approved[0].service.location,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    // Default koordinat untuk Surabaya
    double defaultLng = 112.739861;
    double defaultLat = -7.251840;

    double lng = defaultLng;
    double lat = defaultLat;

    // Gunakan koordinat dari state jika tersedia
    if (widget.booking.services.approved.isNotEmpty &&
        widget.booking.services.approved[0].option == 'Offline' &&
        _mapBloc.state is MapLoaded) {
      lng = (_mapBloc.state as MapLoaded)
          .destinationCoordinates
          .coordinates
          .lng
          .toDouble();
      lat = (_mapBloc.state as MapLoaded)
          .destinationCoordinates
          .coordinates
          .lat
          .toDouble();
      debugPrint('Menggunakan koordinat dari state: $lng, $lat');
    } else {
      debugPrint('Menggunakan koordinat default: $defaultLng, $defaultLat');
    }

    return mapbox.MapWidget(
      key: const ValueKey('mapWidget'),
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(lng, lat),
        ),
        zoom: 13.0, // Zoom lebih dekat agar lokasi lebih terlihat
      ),
      onMapCreated: _onMapCreated,
    );
  }

  void _onMapCreated(mapbox.MapboxMap mapboxMap) {
    debugPrint('Map created successfully');

    // Pastikan widget masih mounted sebelum update state
    if (!mounted) return;

    setState(() {
      _mapboxMap = mapboxMap;
    });

    // Tambahkan delay singkat untuk memastikan peta dimuat sepenuhnya
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
      // Pastikan marker ditambahkan segera jika data sudah ada
      _checkAndAddMarker();
    });

    // Dan juga buat listener state untuk menambahkan marker ketika data tersedia
    _mapBloc.stream.listen((state) {
      if (!mounted)
        return; // Jangan lakukan update jika widget sudah tidak mounted

      debugPrint('Current state in stream listener: ${state.runtimeType}');

      if (state is MapLoaded && !_markerAdded && _mapboxMap != null) {
        debugPrint('MapLoaded state detected in stream listener');
        _addDestinationMarker(state.destinationCoordinates);
        _markerAdded = true;
      }

      if (state is CurrentLocationLoaded &&
          !_currentMarkerAdded &&
          _mapboxMap != null) {
        debugPrint('CurrentLocationLoaded state detected in stream listener');
        _addCurrentLocationMarker(state.currentLocation);
        _currentMarkerAdded = true;
      }

      // Memastikan state card info diupdate
      if (state is RouteCalculated && mounted) {
        setState(() {
          _distance = state.distance;
          _duration = state.duration;
        });
      }
    });
  }

  void _checkAndAddMarker() {
    // Validasi 1: MapboxMap sudah diinisialisasi?
    if (_mapboxMap == null) {
      debugPrint('MapboxMap is not initialized. Cannot add markers.');
      return;
    }

    // Validasi 2: Data tujuan + marker belum ditambah?
    if (_mapBloc.state is MapLoaded && !_markerAdded) {
      debugPrint('Adding destination marker.');
      _addDestinationMarker(
          (_mapBloc.state as MapLoaded).destinationCoordinates);
      _markerAdded = true;
    } else {
      debugPrint('State is not MapLoaded or marker already added.');
    }

    // Validasi 3: Data lokasi user + marker belum ditambah?
    if (_mapBloc.state is CurrentLocationLoaded && !_currentMarkerAdded) {
      debugPrint('Adding current location marker.');
      _addCurrentLocationMarker(
          (_mapBloc.state as CurrentLocationLoaded).currentLocation);
      _currentMarkerAdded = true;
    } else {
      debugPrint(
          'State is not CurrentLocationLoaded or current marker already added.');
    }
  }

  Future<void> _drawRoute(mapbox.LineString routeGeometry) async {
    if (_mapboxMap == null) return;

    try {
      // Remove any existing routes
      await _removeExistingLayers();

      // Pemeriksaan tambahan untuk memastikan map masih valid
      if (_mapboxMap == null || !mounted) return;

      try {
        // Pengecekan validasi routeGeometry
        if (routeGeometry == null || routeGeometry.coordinates.isEmpty) {
          debugPrint(
              'Route geometry is null or empty. Cannot add route source.');
          return;
        }

        // PENDEKATAN ALTERNATIF: Gunakan PolylineAnnotation
        debugPrint(
            'Menggunakan pendekatan PolylineAnnotation untuk menggambar rute');

        // configuration untuk menggambar garis di map
        final polylineManager =
            await _mapboxMap!.annotations.createPolylineAnnotationManager();

        // Buat polyline annotation options
        mapbox.PolylineAnnotationOptions polylineOptions =
            mapbox.PolylineAnnotationOptions(
          geometry: routeGeometry,
          lineWidth: 5.0,
          lineColor: 0xFF0077CC, // Warna biru
        );

        // Buat polyline
        await polylineManager.create(polylineOptions);
        debugPrint('Polyline annotation untuk rute berhasil dibuat');
// Memastikan route + markers selalu lengkap
        // Tambahkan marker jika belum
        if (_mapBloc.state is MapLoaded && !_markerAdded) {
          final state = _mapBloc.state as MapLoaded;
          await _addDestinationMarker(state.destinationCoordinates);
          _markerAdded = true;
        }

        // Tambahkan marker lokasi saat ini jika belum
        if (_mapBloc.state is CurrentLocationLoaded && !_currentMarkerAdded) {
          final currentState = _mapBloc.state as CurrentLocationLoaded;
          await _addCurrentLocationMarker(currentState.currentLocation);
          _currentMarkerAdded = true;
        }
      } catch (e) {
        debugPrint('Error menambahkan polyline annotation: $e');
        return; // Keluar dari fungsi jika terjadi error
      }

      // Set camera to show entire route
      // menyesuaikan camera dan zoom dalam satu tampilan (auto-fit)
      final coordinates = routeGeometry.coordinates;
      if (coordinates.isNotEmpty && mounted && _mapboxMap != null) {
        // Create bounds that include both start and end points
        double minLng = coordinates[0].lng.toDouble();
        double maxLng = coordinates[0].lng.toDouble();
        double minLat = coordinates[0].lat.toDouble();
        double maxLat = coordinates[0].lat.toDouble();

        for (var pos in coordinates) {
          if (pos.lng.toDouble() < minLng) minLng = pos.lng.toDouble();
          if (pos.lng.toDouble() > maxLng) maxLng = pos.lng.toDouble();
          if (pos.lat.toDouble() < minLat) minLat = pos.lat.toDouble();
          if (pos.lat.toDouble() > maxLat) maxLat = pos.lat.toDouble();
        }

        final southwest =
            mapbox.Point(coordinates: mapbox.Position(minLng, minLat));
        final northeast =
            mapbox.Point(coordinates: mapbox.Position(maxLng, maxLat));

        final cameraBounds = mapbox.CoordinateBounds(
          infiniteBounds: false,
          southwest: southwest,
          northeast: northeast,
        );

        // Corrected camera bounds configuration
        try {
          final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
              cameraBounds,
              mapbox.MbxEdgeInsets(
                top: 100.0,
                left: 100.0,
                bottom: 300.0,
                right: 100.0,
              ),
              null, // bearing
              null, // pitch
              16.0, // maxZoom
              null // offset
              );

          if (mounted && _mapboxMap != null) {
            await _mapboxMap!.setCamera(cameraOptions);
          }
        } catch (e) {
          debugPrint('Error setting camera: $e');
        }

        // Memastikan data jarak dan durasi tersedia di state
        if (mounted) {
          setState(() {
            if (_distance == null || _duration == null) {
              if (_mapBloc.state is RouteCalculated) {
                final routeState = _mapBloc.state as RouteCalculated;
                _distance = routeState.distance;
                _duration = routeState.duration;
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error drawing route: $e');
    }
  }

  Future<void> _addDestinationMarker(mapbox.Point destination) async {
    if (_mapboxMap == null) {
      debugPrint('Cannot add marker, mapboxMap is null');
      return;
    }

    try {
      if (destination == null) {
        debugPrint('Destination is null. Cannot add destination marker.');
        return;
      }

      debugPrint(
          'Adding marker at: ${destination.coordinates.lng}, ${destination.coordinates.lat}');

      // Menggunakan Circle Annotation untuk destination marker karena lebih terlihat
      final circleManager =
          await _mapboxMap!.annotations.createCircleAnnotationManager();

      // Buat circle untuk lokasi tujuan
      mapbox.CircleAnnotationOptions circleOptions =
          mapbox.CircleAnnotationOptions(
        geometry: destination,
        circleRadius: 12.0,
        circleColor: 0xFFFF0000, // Merah
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF, // Border putih
      );

      await circleManager.create(circleOptions);

      // Tambahkan label untuk lokasi
      final pointManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();
      mapbox.PointAnnotationOptions labelOptions =
          mapbox.PointAnnotationOptions(
              geometry: destination,
              textField: "📍", // Icon pin
              textSize: 20.0,
              textColor: 0xFFFF0000, // Merah
              textOffset: [0, -0.8] // Tempatkan teks di atas lingkaran
              );
      // Buat label annotation
      await pointManager.create(labelOptions);

      debugPrint('Destination marker created successfully');

      // Set camera to focus on this point
      final cameraOptions = mapbox.CameraOptions(
        center: destination,
        zoom: 15.0,
      );
      await _mapboxMap!.setCamera(cameraOptions);
    } catch (e) {
      debugPrint('Error adding destination marker: $e');
      // Fallback sudah tidak diperlukan karena pendekatan di atas seharusnya berfungsi
    }
  }

  Future<void> _addCurrentLocationMarker(mapbox.Point currentLocation) async {
    if (_mapboxMap == null) {
      debugPrint('Cannot add current location marker, mapboxMap is null');
      return;
    }

    try {
      debugPrint(
          'Adding current location marker at: ${currentLocation.coordinates.lng}, ${currentLocation.coordinates.lat}');

      // Menggunakan Circle Annotation untuk current location marker
      final circleManager =
          await _mapboxMap!.annotations.createCircleAnnotationManager();

      // Lingkaran dalam (pusat lokasi)
      mapbox.CircleAnnotationOptions innerCircleOptions =
          mapbox.CircleAnnotationOptions(
        geometry: currentLocation,
        circleRadius: 8.0,
        circleColor: 0xFF0000FF, // Biru
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF, // Border putih
      );

      await circleManager.create(innerCircleOptions);

      // Lingkaran luar sebagai "ripple effect"
      mapbox.CircleAnnotationOptions outerCircleOptions =
          mapbox.CircleAnnotationOptions(
        geometry: currentLocation,
        circleRadius: 14.0,
        circleColor: 0x500000FF, // Biru transparan
        circleStrokeWidth: 1.0,
        circleStrokeColor: 0x80FFFFFF, // Border putih transparan
      );

      await circleManager.create(outerCircleOptions);

      // Tambahkan label untuk lokasi saat ini
      final pointManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();
      mapbox.PointAnnotationOptions labelOptions =
          mapbox.PointAnnotationOptions(
              geometry: currentLocation,
              textField: "📱", // Icon smartphone
              textSize: 16.0,
              textColor: 0xFF0000FF, // Biru
              textOffset: [0, -0.8] // Tempatkan teks di atas lingkaran
              );

      await pointManager.create(labelOptions);

      debugPrint('Current location marker created successfully');
    } catch (e) {
      debugPrint('Error adding current location marker: $e');
      // Fallback sudah tidak diperlukan karena pendekatan di atas seharusnya berfungsi
    }
  }

// Menghapus layer dan source yang ada
  // Ini untuk membersihkan layer lama sebelum menambahkan yang baru, mencegah overlap dan konflik visual
  Future<void> _removeExistingLayers() async {
    if (_mapboxMap == null || !mounted) return;

    try {
      // Hapus layer dan source untuk GeoJSON (pendekatan lama)
      final layersToRemove = ["routeLayer"];
      final sourcesToRemove = ["route"];

      // Hapus layer
      for (var layerId in layersToRemove) {
        try {
          bool layerExists = await _mapboxMap!.style.styleLayerExists(layerId);
          if (layerExists) {
            await _mapboxMap!.style.removeStyleLayer(layerId);
            // Tunggu sejenak setelah menghapus setiap layer
            await Future.delayed(Duration(milliseconds: 100));
          }
        } catch (e) {
          debugPrint('Error removing layer $layerId: $e');
          // Lanjutkan dengan layer berikutnya bahkan jika terjadi error
          continue;
        }
      }

      // Tunggu sejenak sebelum menghapus source
      await Future.delayed(Duration(milliseconds: 200));

      // Hapus source
      for (var sourceId in sourcesToRemove) {
        try {
          bool sourceExists =
              await _mapboxMap!.style.styleSourceExists(sourceId);
          if (sourceExists) {
            await _mapboxMap!.style.removeStyleSource(sourceId);
            // Tunggu sejenak setelah menghapus setiap source
            await Future.delayed(Duration(milliseconds: 100));
          }
        } catch (e) {
          debugPrint('Error removing source $sourceId: $e');
          // Lanjutkan dengan source berikutnya bahkan jika terjadi error
          continue;
        }
      }

      // Bersihkan juga annotation untuk polyline (pendekatan baru)
      try {
        final annotationManager = await _mapboxMap!.annotations;
        final polylineManager =
            await annotationManager.createPolylineAnnotationManager();
        await polylineManager.deleteAll();
        debugPrint('Polyline annotations cleaned up');
      } catch (e) {
        debugPrint('Error cleaning up polyline annotations: $e');
      }

      // Tunggu sejenak untuk memastikan semua operasi penghapusan selesai
      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Error removing layers: $e');
    }
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPallete.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ColorPallete.primaryColor, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                isLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menambahkan marker untuk titik tengah rute
  Future<void> _addMidpointMarker(mapbox.Point midPoint) async {
    if (_mapboxMap == null) {
      debugPrint('Cannot add midpoint marker, mapboxMap is null');
      return;
    }

    try {
      debugPrint(
          'Adding midpoint marker at: ${midPoint.coordinates.lng}, ${midPoint.coordinates.lat}');

      // Create marker for midpoint
      final pointAnnotationManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();

      mapbox.PointAnnotationOptions options = mapbox.PointAnnotationOptions(
          geometry: midPoint,
          iconSize: 0.8,
          iconOffset: [0, 0],
          textField: "😎",
          textColor: 0xFF00CCAA,
          textSize: 12.0,
          iconImage: "😁");

      final pointAnnotation = await pointAnnotationManager.create(options);
      debugPrint('Midpoint annotation created: ${pointAnnotation.id}');
    } catch (e) {
      debugPrint('Error adding midpoint marker: $e');
    }
  }

  // Mengkonversi data service booking menjadi LocationModel yang bisa diproses oleh MapBloc untuk geocoding dan menampilkan lokasi di peta.
  LocationModel _extractLocationFromService() {
    if (widget.booking.services.approved.isEmpty) {
      return LocationModel(address: 'Default Location');
    }

    final service = widget.booking.services.approved[0].service;

    // Coba ekstrak berbagai format data lokasi dari service
    // Priority 1: Cek jika ada field latitude/longitude terpisah
    double? lat;
    double? lng;

    // Asumsi service memiliki field seperti service.latitude, service.longitude
    // Anda perlu menyesuaikan dengan struktur model Service yang sebenarnya
    try {
      // Contoh: service.latitude dan service.longitude (sesuaikan dengan model Anda)
      if (service.toString().contains('latitude') &&
          service.toString().contains('longitude')) {
        // Implementasi untuk mengekstrak lat/lng jika ada di model service
        // lat = service.latitude;
        // lng = service.longitude;
      }
    } catch (e) {
      debugPrint('Error extracting coordinates from service: $e');
    }

    // Priority 2: Gunakan alamat yang ada
    String address = service.location.trim();

    // Priority 3: Gunakan nama service sebagai fallback
    String name = service.title;

    return LocationModel(
      name: name.isNotEmpty ? name : null,
      latitude: lat,
      longitude: lng,
      address: address.isNotEmpty ? address : null,
    );
  }
}
