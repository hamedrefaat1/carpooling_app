// map_display_cubit.dart
// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'package:carpooling_app/business_logic/cubits/MapDisplayCubit/MapDisplayStates.dart';
import 'package:carpooling_app/data/models/TripVisualizationData.dart';
import 'package:carpooling_app/data/models/UserLocationData.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapDisplayCubit extends Cubit<MapDisplayStates> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  StreamSubscription<QuerySnapshot>? _tripsSubscription;
  
  List<UserLocationData> _userLocations = [];
  List<TripVisualizationData> _activeTrips = [];

  MapDisplayCubit() : super(MapDisplayInitial());

  Future<void> startListeningToMapData() async {
    try {
      emit(MapDisplayLoading());
      
      // Listen to users locations
      _startListeningToUsers();
      
      // Listen to active trips
      _startListeningToTrips();
      
    } catch (e) {
      emit(MapDisplayError('Failed to load map data: $e'));
    }
  }

  void _startListeningToUsers() {
    _usersSubscription = _firestore
        .collection('Users')
        .where('status', isEqualTo: 'online')
        .snapshots()
        .listen((snapshot) {
      
      _userLocations = snapshot.docs.map((doc) {
        return UserLocationData.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      _emitUpdatedState();
    }, onError: (error) {
      emit(MapDisplayError('Error loading users: $error'));
    });
  }
   
   void _startListeningToTrips() {
  _tripsSubscription = _firestore
      .collection('trips')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .listen((snapshot) async {
    
    try {
      List<TripVisualizationData> trips = [];
      
      for (var tripDoc in snapshot.docs) {
        var tripData = tripDoc.data() as Map<String, dynamic>;
        
        // acccepted join requestes just
        var joinRequestsSnapshot = await _firestore
            .collection('trips')
            .doc(tripDoc.id)
            .collection('joinRequests')
            .where('status', isEqualTo: 'accepted') // فقط المقبولة
            .get();
        
        // swap accepted JoinRequests  to PassengerData
        List<PassengerData> acceptedPassengers = [];
        
        for (var joinRequestDoc in joinRequestsSnapshot.docs) {
          var joinRequestData = joinRequestDoc.data();
          var joinRequest = JoinRequest.fromJson(joinRequestData, documentId: joinRequestDoc.id);
          
           // swap accepted JoinRequests  to PassengerData
          acceptedPassengers.add(PassengerData(
            passengerId: joinRequest.riderId,
            passengerName: joinRequest.ridername,
            lat: joinRequest.riderLocation['lat']?.toDouble() ?? 0.0,
            lng: joinRequest.riderLocation['lng']?.toDouble() ?? 0.0, phoneNumber: '',
          ));
        }
        
        // Get driver information
        String driverId = tripData['driverId'];
        var driverDoc = await _firestore.collection('Users').doc(driverId).get();
        String driverName = 'Unknown Driver';
        
        if (driverDoc.exists) {
          var driverData = driverDoc.data() as Map<String, dynamic>;
          driverName = driverData['fullName'] ?? 'Unknown Driver';
        }
        
        trips.add(TripVisualizationData(
          tripId: tripDoc.id,
          driverId: driverId,
          driverName: driverName,
          driverLat: tripData['driverLocation']['lat']?.toDouble() ?? 0.0,
          driverLng: tripData['driverLocation']['lng']?.toDouble() ?? 0.0,
          destinationLat: tripData['destination']['lat']?.toDouble() ?? 0.0,
          destinationLng: tripData['destination']['lng']?.toDouble() ?? 0.0,
          destinationName: tripData['destination']['name'] ?? 'Unknown Destination',
          acceptedPassengers: acceptedPassengers, // فقط الركاب المقبولين
        ));
      }
      
      _activeTrips = trips;
      _emitUpdatedState();
      
    } catch (e) {
      emit(MapDisplayError('Error processing trips: $e'));
    }
  }, onError: (error) {
    emit(MapDisplayError('Error loading trips: $error'));
  });
}


  void _emitUpdatedState() {
    emit(MapDisplayLoaded(
      userLocations: List.from(_userLocations),
      activeTrips: List.from(_activeTrips),
    ));
  }

  // Get current user's trips (for drivers to see their trips)
  List<TripVisualizationData> getCurrentUserTrips() {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];
    
    return _activeTrips.where((trip) => trip.driverId == currentUserId).toList();
  }

  // Get trips that current user is passenger in
  List<TripVisualizationData> getTripsAsPassenger() {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];
    
    return _activeTrips.where((trip) => 
      trip.acceptedPassengers.any((passenger) => passenger.passengerId == currentUserId)
    ).toList();
  }

  // Update user location (call this when user location changes)
  Future<void> updateUserLocation(double lat, double lng) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;
      
      await _firestore.collection('Users').doc(currentUserId).update({
        'location.lat': lat,
        'location.lng': lng,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      emit(MapDisplayError('Failed to update location: $e'));
    }
  }

  // Set user status (online/offline)
  Future<void> setUserStatus(String status) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;
      
      await _firestore.collection('Users').doc(currentUserId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      emit(MapDisplayError('Failed to update status: $e'));
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _tripsSubscription?.cancel();
    return super.close();
  }
}