import 'package:carpooling_app/business_logic/cubits/DriverTripManagement/DriverTripManagementStates.dart';
import 'package:carpooling_app/data/api_services/NotificationService.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverTripManagementCubit extends Cubit<DriverTripManagementStates> {
  DriverTripManagementCubit() : super(DriverTripManagementInitial());

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  // get all driver trips with request counts
  Future<void> getAllDriverTrips() async {
    try {
      emit(DriverTripsLoading());
      final QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection("trips")
          .where("driverId", isEqualTo: currentUserId)
          .orderBy("createdAt", descending: true)
          .get();

      List<TripModel> trips = [];
      Map<String, int> requestsCounts = {};
      for (DocumentSnapshot doc in tripsSnapshot.docs) {
        final tripData = doc.data() as Map<String, dynamic>;
        final trip = TripModel.fromJson(tripData , documentId: doc.id);
        trips.add(trip);

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

  /// handle accept or reject request
  Future<void> handleRequestAction(
    String tripId,
    String requestId,
    String action,
  ) async {
    try {
      emit(RequestActionLoading(action));

      final requestDoc = await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .collection("joinRequests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) throw Exception('Request not found');
      final request = JoinRequest.fromJson(
        requestDoc.data() as Map<String, dynamic>,
        documentId: requestDoc.id,
      );

      final tripDoc =
          await FirebaseFirestore.instance.collection("trips").doc(tripId).get();
      if (!tripDoc.exists) throw Exception('Trip not found');
      final tripData = tripDoc.data() as Map<String, dynamic>;

      final driverDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUserId)
          .get();
      final driverData = driverDoc.data() as Map<String, dynamic>;
      final driverName = driverData['fullName'] ?? 'السائق';

      // renew request status
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
        int currentAvailableSeats = tripData['availableSeats'] ?? 0;
        if (currentAvailableSeats > 0) {
          await FirebaseFirestore.instance
              .collection("trips")
              .doc(tripId)
              .update({"availableSeats": currentAvailableSeats - 1});
        }

        // notify rider about acceptance
        await NotificationService.sendNotificationToUser(
          userId: request.riderId,
          title: "تم قبول طلبك",
          body: "قام $driverName بقبول طلبك للانضمام إلى الرحلة 🚗",
          data: {
            "tripId": tripId,
            "status": "accepted",
            "driverName": driverName,
          },
        );
      } else if (action == 'reject') {
        await FirebaseFirestore.instance
            .collection("trips")
            .doc(tripId)
            .collection("joinRequests")
            .doc(requestId)
            .delete();

        // notify rider about rejection
        await NotificationService.sendNotificationToUser(
          userId: request.riderId,
          title: "تم رفض طلبك",
          body: "قام $driverName برفض طلبك للانضمام إلى الرحلة ❌",
          data: {
            "tripId": tripId,
            "status": "rejected",
            "driverName": driverName,
          },
        );
      }

      emit(RequestActionSuccess(
        action == 'accept'
            ? 'Request accepted successfully!'
            : 'Request rejected successfully!',
        action,
      ));
    } catch (e) {
      emit(RequestActionError(
        'Error ${action == 'accept' ? 'accepting' : 'rejecting'} request: ${e.toString()}',
        action,
      ));
    }
  }



}
