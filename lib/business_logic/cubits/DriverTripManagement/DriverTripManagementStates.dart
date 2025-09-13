


// States
import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/trip_model.dart';

abstract class DriverTripManagementStates {}



class DriverTripManagementInitial extends DriverTripManagementStates {}

class DriverTripsLoading extends DriverTripManagementStates {}

class DriverTripsLoaded extends DriverTripManagementStates {
  final List<TripModel> trips;
  final Map<String, int> requestsCounts;

  DriverTripsLoaded({required this.trips , required this.requestsCounts});

}

class DriverTripsError extends DriverTripManagementStates {
  final String errorMessage;
  DriverTripsError(this.errorMessage);
}

class TripRequestsLoading extends DriverTripManagementStates{}

class TripRequestsLoaded extends DriverTripManagementStates{
  List<JoinRequest> requests;
  Map<String, dynamic> ridersData;
  TripRequestsLoaded({required this.requests , required this.ridersData});
}

class TripRequestsError extends DriverTripManagementStates{
  final String errorMessage ;
  TripRequestsError(this.errorMessage);
}

// handling accept/reject actions states
class RequestActionLoading extends DriverTripManagementStates{
  String action ; // accept or reject
  RequestActionLoading(this.action);
}

class RequestActionSuccess extends DriverTripManagementStates{
  final String message ;
  String action;
  RequestActionSuccess(this.message , this.action);
}

class RequestActionError extends DriverTripManagementStates{
  final String errorMessage ;
  String  action;
  RequestActionError(this.errorMessage , this.action);
}

