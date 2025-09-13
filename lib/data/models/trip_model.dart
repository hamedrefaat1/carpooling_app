import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String? id;
  final String driverId;
  final DriverLocation driverLocation; 
  final MapboxPlace destination;
  final String status;
  final List<String> passengers;
  final int maxPassengers;
  final int availableSeats;
  final DateTime? createdAt;

  TripModel({
    this.id,
    required this.driverId,
    this.createdAt,
    required this.destination,
    required this.driverLocation,
    required this.status,
    required this.availableSeats,
    required this.maxPassengers,
    required this.passengers,
  });

  // Fixed factory method - removed extra String id parameter
  factory TripModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return TripModel(
      id: documentId,
      driverId: json["driverId"] ?? '',
      destination: MapboxPlace.fromFirestore(json["destination"] ?? {}),
      driverLocation: DriverLocation.fromJson(json["driverLocation"] ?? {}), // fixed typo
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      passengers: List<String>.from(json['passengers'] ?? []),
      maxPassengers: json['maxPassengers'] ?? 4,
      availableSeats: json['availableSeats'] ?? 4,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverLocation': driverLocation.toJson(),
      'destination': destination.toJson(),
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'passengers': passengers,
      'maxPassengers': maxPassengers,
      'availableSeats': availableSeats,
    };
  }
}


class DriverLocation {
  double? lat;
  double? lng;

  DriverLocation({required this.lat, required this.lng});

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      lat: (json["lat"] ?? 0.0).toDouble(),
      lng: (json["lng"] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"lat": lat, "lng": lng};
  }
}