


import 'package:carpooling_app/data/models/riderRiderRequestWithTripData.dart';

abstract class RiderJoinRequestsStates {}

class RiderJoinRequestsInitial extends RiderJoinRequestsStates {}

class RiderJoinRequestsLoading extends RiderJoinRequestsStates {}

class RiderJoinRequestsLoaded extends RiderJoinRequestsStates {
  final List<RiderRequestWithTripData> requests;
  RiderJoinRequestsLoaded({required this.requests});
}

class RiderJoinRequestsError extends RiderJoinRequestsStates {
  final String errorMessage;
  RiderJoinRequestsError(this.errorMessage);
}