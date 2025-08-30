// Cubit
import 'dart:io';

import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class DriverTripManagementCubit extends Cubit<DriverTripManagementStates> {
  DriverTripManagementCubit() : super(DriverTripManagementInitial());

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  // get ll driver trips with request counts
  Future<void> getAllDriverTrips() async {
    try {
      emit(DriverTripsLoading());
      // get diver trips
      final QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection("trips")
          .where("driverId", isEqualTo: currentUserId)
          .orderBy("createdAt", descending: true)
          .get();

      List<TripModel> trips = [];
      Map<String, int> requestsCounts = {};
      for (DocumentSnapshot doc in tripsSnapshot.docs) {
        final tripData = doc.data() as Map<String, dynamic>;
        final trip = TripModel.fromJson(tripData, documentId: doc.id);
        trips.add(trip);
        // get pending requests count for each trip
        final requestsSnapshot = await FirebaseFirestore.instance
            .collection("trips")
            .doc(doc.id)
            .collection("joinRequests")
            .where("status", isEqualTo: "pending")
            .get();

        requestsCounts[doc.id] = requestsSnapshot.docs.length;
      }
      emit(DriverTripsLoaded(trips: trips, requestsCounts: requestsCounts));
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  // get all requests for specific trip
  Future<void> getAllTripRequests(String tripId) async {
    try {
      emit(TripRequestsLoading());

      final QuerySnapshot requestsSnapshot = await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .collection("joinRequests")
          .orderBy("requestedAt", descending: true)
          .get();

      List<JoinRequest> requests = [];
      Map<String, dynamic> ridersData = {};
      for (var doc in requestsSnapshot.docs) {
        final requestData = doc.data() as Map<String, dynamic>;
        final request = JoinRequest.fromJson(requestData, documentId: doc.id);
        requests.add(request);

        // get rider data
        final DocumentSnapshot riderData = await FirebaseFirestore.instance
            .collection("Users")
            .doc(request.riderId)
            .get();
        final riderInfo = riderData.data() as Map<String, dynamic>;
        ridersData[request.riderId] = riderInfo;
      }
      emit(TripRequestsLoaded(requests: requests, ridersData: ridersData));
    } catch (e) {
      emit(TripRequestsError(e.toString()));
    }
  }

  // refactor accept/reject methods to reduce code duplication
  Future<void> handleRequestAction(
    String tripId,
    String requestId,
    String action,
  ) async {
    try {
      emit(RequestActionLoading(action));

      // update request status
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .collection("joinRequests")
          .doc(requestId)
          .update({
            "status": action == 'accept' ? 'accepted' : 'rejected',
            "responsedAt": FieldValue.serverTimestamp(),
          });
      if (action == 'accept') {
        // get trip data to update avilable sets
        final tripDoc = await FirebaseFirestore.instance
            .collection("trips")
            .doc(tripId)
            .get();
        if (tripDoc.exists) {
          final tripData = tripDoc.data() as Map<String, dynamic>;
          int currentAvailableSeats = tripData['availableSeats'] ?? 0;
          if (currentAvailableSeats > 0) {
            // decrease avilable sets by 1 in the car
            await FirebaseFirestore.instance
                .collection("trips")
                .doc(tripId)
                .update({"availableSeats": currentAvailableSeats - 1});
          }
        }
      }
      if (action == 'reject') {
        //  delete the request document
        await FirebaseFirestore.instance
            .collection("trips")
            .doc(tripId)
            .collection("joinRequests")
            .doc(requestId)
            .delete();
      }

      // ToDo send notification to rider about the action
      emit(
        RequestActionSuccess(
          action == 'accept'
              ? 'Request accepted successfully!'
              : 'Request rejected successfully!',
          action,
        ),
      );
    } catch (e) {
      emit(
        RequestActionError(
          'Error ${action == 'accept' ? 'accepting' : 'rejecting'} request: ${e.toString()}',
          action,
        ),
      );
    }
  }

  // Get all driver trips with request counts
  // Future<void> loadDriverTrips() async {
  //   try {
  //     emit(DriverTripsLoading());

  //     // Get driver trips
  //     final QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
  //         .collection('trips')
  //         .where('driverId', isEqualTo: currentUserId)
  //         .orderBy('createdAt', descending: true)
  //         .get();

  //     List<TripModel> trips = [];
  //     Map<String, int> requestCounts = {};

  //     for (var doc in tripsSnapshot.docs) {
  //       final tripData = doc.data() as Map<String, dynamic>;
  //       final trip = TripModel.fromJson(tripData, documentId: doc.id);
  //       trips.add(trip);

  //       // Count pending requests for each trip
  //       final requestsSnapshot = await FirebaseFirestore.instance
  //           .collection('trips')
  //           .doc(doc.id)
  //           .collection('joinRequests')
  //           .where('status', isEqualTo: 'pending')
  //           .get();

  //       requestCounts[doc.id] = requestsSnapshot.docs.length;
  //     }

  //     emit(DriverTripsLoaded(trips: trips, requestsCounts: requestCounts));

  //   } catch (e) {
  //     emit(DriverTripsError('Error loading trips: ${e.toString()}'));
  //   }
  // }

  // Get requests for specific trip
  // Future<void> loadTripRequests(String tripId) async {
  //   try {
  //     emit(TripRequestsLoading(tripId));

  //     final QuerySnapshot requestsSnapshot = await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .collection('joinRequests')
  //         .orderBy('requestedAt', descending: true)
  //         .get();

  //     List<JoinRequest> requests = [];

  //     for (var doc in requestsSnapshot.docs) {
  //       final requestData = doc.data() as Map<String, dynamic>;
  //       final request = JoinRequest.fromJson(requestData, documentId: doc.id);
  //       requests.add(request);
  //     }

  //     emit(TripRequestsLoaded(tripId: tripId, requests: requests));

  //   } catch (e) {
  //     emit(TripRequestsError(
  //       tripId: tripId,
  //       errorMessage: 'Error loading requests: ${e.toString()}',
  //     ));
  //   }
  // }

  // Accept join request
  // Future<void> acceptRequest(String tripId, String requestId) async {
  //   try {
  //     emit(RequestActionLoading(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'accept',
  //     ));

  //     // Update request status to accepted
  //     await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .collection('joinRequests')
  //         .doc(requestId)
  //         .update({
  //       'status': 'accepted',
  //       'responsedAt': FieldValue.serverTimestamp(),
  //     });

  //     // Get trip data to update available seats
  //     final tripDoc = await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .get();

  //     if (tripDoc.exists) {
  //       final tripData = tripDoc.data() as Map<String, dynamic>;
  //       int currentAvailableSeats = tripData['availableSeats'] ?? 0;

  //       if (currentAvailableSeats > 0) {
  //         // Decrease available seats by 1
  //         await FirebaseFirestore.instance
  //             .collection('trips')
  //             .doc(tripId)
  //             .update({
  //           'availableSeats': currentAvailableSeats - 1,
  //         });
  //       }
  //     }

  //     // TODO: Send notification to rider

  //     emit(RequestActionSuccess(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'accept',
  //       message: 'Request accepted successfully!',
  //     ));

  //     // Reload requests to show updated list
  //     await loadTripRequests(tripId);

  //   } catch (e) {
  //     emit(RequestActionError(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'accept',
  //       errorMessage: 'Error accepting request: ${e.toString()}',
  //     ));
  //   }
  // }

  // // Reject join request
  // Future<void> rejectRequest(String tripId, String requestId) async {
  //   try {
  //     emit(RequestActionLoading(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'reject',
  //     ));

  //     // Update request status to rejected
  //     await FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(tripId)
  //         .collection('joinRequests')
  //         .doc(requestId)
  //         .update({
  //       'status': 'rejected',
  //       'responsedAt': FieldValue.serverTimestamp(),
  //     });

  //     // TODO: Send notification to rider

  //     emit(RequestActionSuccess(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'reject',
  //       message: 'Request rejected successfully!',
  //     ));

  //     // Reload requests to show updated list
  //     await loadTripRequests(tripId);

  //   } catch (e) {
  //     emit(RequestActionError(
  //       tripId: tripId,
  //       requestId: requestId,
  //       action: 'reject',
  //       errorMessage: 'Error rejecting request: ${e.toString()}',
  //     ));
  //   }
  // }

  // // Get rider details
  // Future<Map<String, dynamic>?> getRiderDetails(String riderId) async {
  //   try {
  //     final DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(riderId)
  //         .get();

  //     if (userDoc.exists) {
  //       return userDoc.data() as Map<String, dynamic>;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error getting rider details: $e');
  //     return null;
  //   }
  // }
}
