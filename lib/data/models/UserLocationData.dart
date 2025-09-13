// Data models for map display
class UserLocationData {
  final String userId;
  final String name;
  final String type; 
  final double lat;
  final double lng;
  final String status;

  UserLocationData({
    required this.userId,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.status,
  });

  factory UserLocationData.fromFirestore(String id, Map<String, dynamic> data) {
    return UserLocationData(
      userId: id,
      name: data['fullName'] ?? 'Unknown',
      type: data['type'] ?? 'passenger',
      lat: data['location']['lat']?.toDouble() ?? 0.0,
      lng: data['location']['lng']?.toDouble() ?? 0.0,
      status: data['status'] ?? 'offline',
    );
  }
}