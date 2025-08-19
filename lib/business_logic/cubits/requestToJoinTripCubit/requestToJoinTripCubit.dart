import 'dart:math';

import 'package:carpooling_app/business_logic/cubits/requestToJoinTripCubit/requestToJoinTripStetes.dart';
import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:carpooling_app/data/repositories/mapbox_srearchPlacesRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Requesttojointripcubit extends Cubit<RiderTripSearchStates> {
  final MapboxSrearchplacesrepo _mapboxSrearchplacesrepo =
      MapboxSrearchplacesrepo();
  MapboxPlace? _selectedPlace;
  Requesttojointripcubit() : super(RiderPlacesSearchInitial());

  // serach about places
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

    print('Places received: ${places.length}'); // للتديبوق

    if (places.isEmpty) {
      emit(RiderPlacesSearchError('No places found for "$query"'));
      return;
    }

    // تأكد من إظهار النتائج
    emit(RiderPlacesSearchSuccess(
      places: places,
      showSuggestions: true, // مهم: إظهار الاقتراحات
    ));
  } catch (e) {
    print('Search error: $e'); // للتديبوق
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
  emit(PlaceSelected(place)); // تغيير من Error إلى PlaceSelected
  
  // البحث عن الرحلات
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
        // ترتيب الرحلات حسب المسافة (الأقرب أولاً)
        // قبل السورت، هنجهز بيانات السواقين
        Map<String, Map<String, dynamic>> driversData = {};
        for (var trip in availableTrips) {
          final driverData = await _getDriverCurrentData(trip.driverId);
          if (driverData != null) {
            driversData[trip.driverId] = driverData;
          }
        }

        //  نعمل sort
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
