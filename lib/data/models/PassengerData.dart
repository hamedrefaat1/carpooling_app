class PassengerData {
  final String passengerId;
  final String passengerName;
  final double lat;
  final double lng;
  
  PassengerData({
    required this.passengerId,
    required this.passengerName,
    required this.lat,
    required this.lng,
  });
  
  factory PassengerData.fromFirestore(Map<String, dynamic> data) {
    return PassengerData(
      passengerId: data['passengerId'] ?? '',
      passengerName: data['passengerName'] ?? '',
      lat: data['lat']?.toDouble() ?? 0.0,
      lng: data['lng']?.toDouble() ?? 0.0,
    );
  }
}