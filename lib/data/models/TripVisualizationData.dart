class TripVisualizationData {
  final String tripId;
  final String driverId;
  final String driverName;
  final double driverLat;
  final double driverLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final List<PassengerData> acceptedPassengers;

  TripVisualizationData({
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.driverLat,
    required this.driverLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    required this.acceptedPassengers,
  });
}

class PassengerData {
  final String passengerId;
  final String passengerName;
  final double lat;
  final double lng;
  final String phoneNumber;

  PassengerData({
    required this.passengerId,
    required this.passengerName,
    required this.lat,
    required this.lng,
    required this.phoneNumber,
  });

  factory PassengerData.fromFirestore(Map<String, dynamic> data) {
    return PassengerData(
      passengerId: data['riderId'] ?? '',
      passengerName: data['ridername'] ?? 'Unknown',
      lat: data['riderLocation']['lat']?.toDouble() ?? 0.0,
      lng: data['riderLocation']['lng']?.toDouble() ?? 0.0,
      phoneNumber: data['riderPhoneNumber'] ?? '',
    );
  }
}