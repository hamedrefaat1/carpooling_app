import 'package:carpooling_app/data/models/join_request.dart';
import 'package:carpooling_app/data/models/trip_model.dart';

class RiderRequestWithTripData{
  final JoinRequest request;
  final TripModel tripData;
  final Map<String , dynamic> driverData;

  RiderRequestWithTripData({required this.request , required this.tripData , required this.driverData});
}