import 'package:carpooling_app/data/models/mapbox_place.dart';

abstract class PlaceSearchState {}

class PlaceSearchInitial extends PlaceSearchState {}

class PlaceSearchLoading extends PlaceSearchState {}

class PlaceSearchSuccess extends PlaceSearchState {
  final List<MapboxPlace> places;
  final bool showSuggestions;
  PlaceSearchSuccess({required this.places, this.showSuggestions = true});
}

class PlaceSearchError extends PlaceSearchState {
  final String erorrMessage;
  PlaceSearchError(this.erorrMessage);
}

class PlaceSelected extends PlaceSearchState {
  final MapboxPlace selectedPlace;
  PlaceSelected(this.selectedPlace);
}

class TripPublishing extends PlaceSearchState {
  final MapboxPlace place;
  TripPublishing(this.place);

}

class TripPublished extends PlaceSearchState {
  final MapboxPlace place;
  final String message;

   TripPublished({
    required this.place,
    required this.message,
  });
}

class TripPublishError extends PlaceSearchState {
 final String erorrMessage;
  TripPublishError(this.erorrMessage);
}
