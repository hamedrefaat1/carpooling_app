import 'package:carpooling_app/business_logic/cubits/riderJoinRequests.dart/riderJoinRequestsStates.dart';
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/riderRiderRequestWithTripData.dart';
import 'package:carpooling_app/data/models/trip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RiderJoinRequestsCubit extends Cubit<RiderJoinRequestsStates> {
  RiderJoinRequestsCubit() : super(RiderJoinRequestsInitial());

  String riderId = FirebaseAuth.instance.currentUser!.uid;
  // get all join requests for the current rider with  trip data
  Future<void> getRiderJoinRequests(String riderId) async {
    emit(RiderJoinRequestsLoading());

    try {
      // get all trips first
      final QuerySnapshot tripsSnapShot = await FirebaseFirestore.instance
          .collection("trips")
          .get();

      List<RiderRequestWithTripData> requests = [];

      for (var tipDoc in tripsSnapShot.docs) {
        final tripData = tipDoc.data() as Map<String, dynamic>;
        final TripModel trip = TripModel.fromJson(
          tripData,
          documentId: tipDoc.id,
        );

        // get join requests for each trip where riderId matches
        final QuerySnapshot joinRequestsSnapshot = await FirebaseFirestore
            .instance
            .collection("trips")
            .doc(trip.id)
            .collection("joinRequests")
            .where("riderId", isEqualTo: riderId)
            .get();

        for (var reqDoc in joinRequestsSnapshot.docs) {
          final reqData = reqDoc.data() as Map<String, dynamic>;
          final JoinRequest request = JoinRequest.fromJson(
            reqData,
            documentId: reqDoc.id,
          );

          // get driver data
          final driverDoc = await FirebaseFirestore.instance
              .collection("Users")
              .doc(trip.driverId)
              .get();
          final driverData = driverDoc.data() as Map<String, dynamic>;

          requests.add(
            RiderRequestWithTripData(
              request: request,
              driverData: driverData,
              tripData: trip,
            ),
          );
        }
      }
      requests.sort((a, b) {
        return b.request.requestedAt.compareTo(a.request.requestedAt);
      });

      emit(RiderJoinRequestsLoaded(requests: requests));
    } catch (e) {
      emit(RiderJoinRequestsError(e.toString()));
    }
  }

  // cancle join request
  Future<void> cancleJoinRequest(String tripId, String requestId ) async {
    await FirebaseFirestore.instance
        .collection("trips")
        .doc(tripId)
        .collection("joinRequests")
        .doc(requestId)
        .delete();

        // refresh to get join requests after cancle this join request
        getRiderJoinRequests(riderId);
  }
}
