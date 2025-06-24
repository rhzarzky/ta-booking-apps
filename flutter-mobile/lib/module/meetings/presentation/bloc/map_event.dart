import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:Appointly/module/meetings/model/location_model.dart';

abstract class MapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMapEvent extends MapEvent {
  final String locationAddress;

  LoadMapEvent(this.locationAddress);

  @override
  List<Object?> get props => [locationAddress];
}

class LoadMapWithLocationEvent extends MapEvent {
  final LocationModel location;

  LoadMapWithLocationEvent(this.location);

  @override
  List<Object?> get props => [location];
}

class GetCurrentLocationEvent extends MapEvent {}

class CalculateRouteEvent extends MapEvent {
  final mapbox.Point destination;

  CalculateRouteEvent(this.destination);

  @override
  List<Object?> get props => [destination];
}
