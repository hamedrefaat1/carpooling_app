import 'package:carpooling_app/data/models/mapbox_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String? id;
  final String driverId;
  final DriverLoaction driverLoaction;
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
    required this.driverLoaction,
    required this.status,
    required this.availableSeats,
    required this.maxPassengers,
    required this.passengers,
  });

  factory TripModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return TripModel(
      id: documentId,
      driverId: json["driverId"] ?? '',
      destination: MapboxPlace.fromFirestore(json["destination"] ?? {}),
      driverLoaction: DriverLoaction.fromJson(json["driverLocation"] ?? {}),
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
      'driverLocation': driverLoaction.toJson(),
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

class DriverLoaction {
  double? lat;
  double? lng;

  DriverLoaction({required this.lat, required this.lng});

  factory DriverLoaction.fromJson(Map<String, dynamic> json) {
    return DriverLoaction(
      lat: (json["lat"] ?? 0.0).toDouble(),
      lng: (json["lng"] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"lat": lat, "lng": lng};
  }
}
