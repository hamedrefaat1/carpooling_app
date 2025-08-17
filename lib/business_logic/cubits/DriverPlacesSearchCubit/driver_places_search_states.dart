import 'package:carpooling_app/data/models/mapbox_place.dart';

abstract class DriverPlacesSearchStates {}

class DriverPlacesSearchInitial extends DriverPlacesSearchStates {}

class DriverPlacesSearchLoading extends DriverPlacesSearchStates {}

class DriverPlacesSearchSuccess extends DriverPlacesSearchStates {
  final List<MapboxPlace> places;
  final bool showSuggestions;
  DriverPlacesSearchSuccess({required this.places, this.showSuggestions = true});

  DriverPlacesSearchSuccess copyWith({
    List<MapboxPlace>? places,
    bool? showSuggestions,
  }) {
    return DriverPlacesSearchSuccess(
      places: places ?? this.places,
      showSuggestions: showSuggestions ?? this.showSuggestions,
    );
  }
}

class DriverPlacesSearchError extends DriverPlacesSearchStates {
  final String erorrMessage;
  DriverPlacesSearchError(this.erorrMessage);
}

class PlaceSelected extends DriverPlacesSearchStates {
  final MapboxPlace selectedPlace;
  PlaceSelected(this.selectedPlace);
}

class DriverTripPublishing extends DriverPlacesSearchStates {
  final MapboxPlace place;
  DriverTripPublishing(this.place);
}

class DriverTripPublished extends DriverPlacesSearchStates {
  final MapboxPlace place;
  final String message;

  DriverTripPublished({required this.place, required this.message});
}

class DriverTripPublishError extends DriverPlacesSearchStates {
  final String erorrMessage;
  DriverTripPublishError(this.erorrMessage);
}
