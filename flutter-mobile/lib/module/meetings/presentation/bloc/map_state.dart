import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  // Menggunakan tipe data yang spesifik dari Mapbox SDK
  final mapbox.Point destinationCoordinates;
  final String destinationName;

  MapLoaded({
    required this.destinationCoordinates,
    required this.destinationName,
  });

  @override
  // Equatable functionality = untuk membandingkan objek berdasarkan nilai yg dimiliki sama
  List<Object?> get props => [destinationCoordinates, destinationName];
}

class CurrentLocationLoaded extends MapState {
  final mapbox.Point currentLocation;

  CurrentLocationLoaded({required this.currentLocation});

  @override
  List<Object?> get props => [currentLocation];
}

class RouteCalculated extends MapState {
  final double distance;
  final double duration;
  final mapbox.LineString routeGeometry;

  RouteCalculated({
    required this.distance,
    required this.duration,
    required this.routeGeometry,
  });

  @override
  List<Object?> get props => [distance, duration, routeGeometry];
}

class MapError extends MapState {
  final String message;

  MapError({required this.message});

  @override
  List<Object?> get props => [message];
}
