// map_display_states.dart
import 'package:carpooling_app/data/models/TripVisualizationData.dart';
import 'package:carpooling_app/data/models/UserLocationData.dart';

abstract class MapDisplayStates {}

class MapDisplayInitial extends MapDisplayStates {}

class MapDisplayLoading extends MapDisplayStates {}

class MapDisplayLoaded extends MapDisplayStates {
  final List<UserLocationData> userLocations;
  final List<TripVisualizationData> activeTrips;

  MapDisplayLoaded({
    required this.userLocations,
    required this.activeTrips,
  });
}

class MapDisplayError extends MapDisplayStates {
  final String errorMessage;

  MapDisplayError(this.errorMessage);
}