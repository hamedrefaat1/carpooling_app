import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:carpooling_app/data/models/trip_model.dart';

abstract class RiderTripSearchStates {}

// ========== Search about Places -> Whre are you Going Now ? ===========
class RiderPlacesSearchInitial extends RiderTripSearchStates {}

class RiderPlacesSearchLoading extends RiderTripSearchStates {}

class RiderPlacesSearchSuccess extends RiderTripSearchStates {
  final List<MapboxPlace> places;
  final bool showSuggestions;
  
  RiderPlacesSearchSuccess({
    required this.places, 
    this.showSuggestions = true
  });

  RiderPlacesSearchSuccess copyWith({
    List<MapboxPlace>? places,
    bool? showSuggestions,
  }) {
    return RiderPlacesSearchSuccess(
      places: places ?? this.places,
      showSuggestions: showSuggestions ?? this.showSuggestions,
    );
  }
}

class RiderPlacesSearchError extends RiderTripSearchStates {
  final String errorMessage;
  RiderPlacesSearchError(this.errorMessage);
}

class PlaceSelected extends RiderTripSearchStates {
  final MapboxPlace selectedPlace;
  PlaceSelected(this.selectedPlace);
}

// ========== Search about avilable Trips Now ==========
class TripsSearchLoading extends RiderTripSearchStates {}

class TripsSearchSuccess extends RiderTripSearchStates {
  final List<TripModel> availableTrips;
  final MapboxPlace destination;
  
  TripsSearchSuccess({
    required this.availableTrips, 
    required this.destination
  });
}

class NoTripsFound extends RiderTripSearchStates {
  final String message;
  final MapboxPlace destination;
  
  NoTripsFound({
    required this.destination,
    this.message = "No trips available to this destination right now."
  });
}

class TripsSearchError extends RiderTripSearchStates {
  final String errorMessage;
  TripsSearchError(this.errorMessage);
}

// ========== Join Requests States ==========
class JoinRequestLoading extends RiderTripSearchStates {
  final String tripId;
  JoinRequestLoading(this.tripId);
}

class JoinRequestSuccess extends RiderTripSearchStates {
  final String tripId;
  final String message;
  
  JoinRequestSuccess({
    required this.tripId,
    this.message = "Join request sent successfully!"
  });
}

class JoinRequestError extends RiderTripSearchStates {
  final String errorMessage;
  final String tripId;
  
  JoinRequestError({
    required this.tripId,
    required this.errorMessage
  });
}

class AlreadyRequestedJoin extends RiderTripSearchStates {
  final String tripId;
  final String message;
  
  AlreadyRequestedJoin({
    required this.tripId,
    this.message = "You have already requested to join this trip."
  });
}

// ========== Is This Trip is FULL?  this state to check trip (Driver Car) is full or Not?   ==========
class TripFull extends RiderTripSearchStates {
  final String tripId;
  final String message;
  
  TripFull({
    required this.tripId,
    this.message = "This trip is full."
  });
}