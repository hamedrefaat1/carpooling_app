import 'dart:math';

import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripStetes.dart';
import 'package:carpooling_app/data/api_services/NotificationService.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:carpooling_app/data/repositories/mapbox_srearchPlacesRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Requesttojointripcubit extends Cubit<RiderTripSearchStates> {
  final MapboxSrearchplacesrepo _mapboxSrearchplacesrepo =
      MapboxSrearchplacesrepo();
  MapboxPlace? _selectedPlace;
  Requesttojointripcubit() : super(RiderPlacesSearchInitial());

  // Get current user data
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  // serach about places
  Future<void> serachPlaces(String query, {String? proximity}) async {
    if (query.isEmpty) {
      emit(RiderPlacesSearchInitial());
      return;
    }

    if (query.length < 3) return;

    emit(RiderPlacesSearchLoading());

    try {
      final places = await _mapboxSrearchplacesrepo.getSerachPlaces(
        query,
        proximity: proximity,
      );

      print('Places received: ${places.length}');

      if (places.isEmpty) {
        emit(RiderPlacesSearchError('No places found for "$query"'));
        return;
      }

      emit(RiderPlacesSearchSuccess(places: places, showSuggestions: true));
    } catch (e) {
      print('Search error: $e');
      emit(RiderPlacesSearchError(e.toString()));
    }
  }

  //  select Place from search result and  search avilable trips
  Future<void> selectPlace(
    MapboxPlace place,
    double riderLat,
    double riderLng,
  ) async {
    _selectedPlace = place;
    emit(PlaceSelected(place));

    // search avilable trips
    await searchAvilableTrips(_selectedPlace!, riderLat, riderLng);
  }

  // search about avilable trips
  Future<void> searchAvilableTrips(
    MapboxPlace destination,
    double riderLat,
    double riderLng,
  ) async {
    emit(TripsSearchLoading());
    try {
      // get all active trips from firebase
      final QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThan: 0)
          .get();

      List<TripModel> availableTrips = [];

      for (var doc in tripsSnapshot.docs) {
        final tripData = doc.data() as Map<String, dynamic>;
        final trip = TripModel.fromJson(tripData, documentId: doc.id);

        if (_isDestinationMatch(trip.destination, destination)) {
          final driverData = await _getDriverCurrentData(trip.driverId);
          if (driverData != null) {
            if (driverData['status'] == 'online') {
              double currentDriverLat = driverData['location']['lat'];
              double currentDriverLng = driverData['location']['lng'];

              double distanceBetweenRiderAndDriverNow = _calculateDistance(
                currentDriverLat,
                currentDriverLng,
                riderLat,
                riderLng,
              );
              if (distanceBetweenRiderAndDriverNow <= 2) {
                availableTrips.add(trip);
              }
            }
          }
        }
      }

      if (availableTrips.isEmpty) {
        emit(NoTripsFound(destination: destination));
      } else {
        // Sort trips by distance from rider (nearest first)

        // before sort we will prepare Drivers data to help us to do sort
        Map<String, Map<String, dynamic>> driversData = {};
        for (var trip in availableTrips) {
          final driverData = await _getDriverCurrentData(trip.driverId);
          if (driverData != null) {
            driversData[trip.driverId] = driverData;
          }
        }

        //  do sort
        availableTrips.sort((a, b) {
          final driverDataA = driversData[a.driverId];
          final driverDataB = driversData[b.driverId];

          if (driverDataA != null && driverDataB != null) {
            double distanceA = _calculateDistance(
              riderLat,
              riderLng,
              driverDataA['location']['lat'],
              driverDataA['location']['lng'],
            );
            double distanceB = _calculateDistance(
              riderLat,
              riderLng,
              driverDataB['location']['lat'],
              driverDataB['location']['lng'],
            );
            return distanceA.compareTo(distanceB);
          }
          return 0;
        });

        emit(
          TripsSearchSuccess(
            availableTrips: availableTrips,
            destination: destination,
          ),
        );
      }
    } catch (e) {
      emit(TripsSearchError('Error searching trips: ${e.toString()}'));
    }
  }

  // send request to join trip
  Future<void> sendRquestToJoinTrip(String tripId) async {
    try {
      emit(JoinRequestLoading(tripId));

      // check if the user already requested to join this trip
      final existingRequestSnapshot = await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .collection("joinRequests")
          .where('riderId', isEqualTo: currentUserId)
          .get();

      if (existingRequestSnapshot.docs.isNotEmpty) {
        emit(AlreadyRequestedJoin(tripId: tripId));

        return;
      }

      // check if trip is still avilable
      final tripDoc = await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .get();
      if (!tripDoc.exists) {
        emit(JoinRequestError(tripId: tripId, errorMessage: 'Trip not found'));
        return;
      }
      // check if trip is active and has available seats
      final tripData = tripDoc.data() as Map<String, dynamic>;
      if (tripData["status"] != 'active') {
        emit(
          JoinRequestError(
            tripId: tripId,
            errorMessage: "this trip not avilable ",
          ),
        );
      }
      if (tripData["availableSeats"] <= 0) {
        emit(
          TripFull(
            tripId: tripId,
          
          ),
        );
        return;
      }

      // create join request

      // get current rider data
      Map<String, dynamic>? riderData = await _getRiderCurrentData(
        currentUserId,
      );
      if (riderData == null) {
        emit(
          JoinRequestError(
            tripId: tripId,
            errorMessage: 'Rider data not found',
          ),
        );
        return;
      }
      final joinRequestRef = FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .collection("joinRequests")
          .doc();

      final joinRequest = JoinRequest(
        id: joinRequestRef.id,
        riderId: currentUserId,
        ridername: riderData["name"] ?? "UNknown",
        riderPhoneNumber: riderData["phoneNumber"] ?? '',
        riderLocation: riderData['location'] ?? {},
        status: "pending",
        requestedAt: DateTime.now()
      );

     // save joinRequest in firebasefireStore
      await joinRequestRef.set(joinRequest.toJson());

      // Send notification to driver 
       await NotificationService.sendNotificationToUser(
        userId: tripData["driverId"],
        title: "طلب انضمام جديد",
        body: "${riderData["name"] ?? "Unknown"} يريد الانضمام إلى رحلتك",
        data: {
          "type": "join_request",
          "tripId": tripId,
          "riderId": currentUserId,
          "riderName": riderData["name"] ?? "Unknown",
        },
      );


      emit(JoinRequestSuccess(tripId : tripId));
    } catch (e) {
      emit(JoinRequestError(tripId: tripId, errorMessage: e.toString()));
    }
  }

  // get current rider data
  Future<Map<String, dynamic>?> _getRiderCurrentData(String riderId) async {
    try {
      final DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(riderId)
          .get();

      if (riderDoc.exists) {
        return riderDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting rider data: $e');
      return null;
    }
  }

  // get driver data
  Future<Map<String, dynamic>?> _getDriverCurrentData(String driverId) async {
    try {
      final DocumentSnapshot driverDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        return driverDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting driver data: $e');
      return null;
    }
  }

  // check place match with
  bool _isDestinationMatch(
    MapboxPlace tripDestination,
    MapboxPlace riderDestinationFromSearch,
  ) {
    // calculate distance between tow detination (tow places)
    double distance = _calculateDistance(
      tripDestination.lat,
      tripDestination.lng,
      riderDestinationFromSearch.lat,
      riderDestinationFromSearch.lng,
    );

    return distance <= 2;
  }

  // calculate distance between tow place by kilo
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // radius of earth by kilometers
    const double earthRadius = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void hideSuggestions() {
    if (state is RiderPlacesSearchSuccess) {
      final currentState = state as RiderPlacesSearchSuccess;
      emit(
        currentState.copyWith(
          places: currentState.places,
          showSuggestions: false,
        ),
      );
    }
  }

  void showSuggestions() {
    if (state is RiderPlacesSearchSuccess) {
      final currentState = state as RiderPlacesSearchSuccess;
      emit(
        currentState.copyWith(
          places: currentState.places,
          showSuggestions: true,
        ),
      );
    }
  }

  void clearSearch() {
    _selectedPlace = null;
    emit(RiderPlacesSearchInitial());
  }
}
