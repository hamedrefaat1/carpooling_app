class MapboxPlace {
  final String name;
  final String fullAddress;
  final double lat;
  final double lng;
  final String? placeType;

  MapboxPlace({
    required this.name,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    this.placeType,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final coordinates = json['geometry']['coordinates'];

    String? type;
    if (json['properties'] != null && json['properties']['category'] != null) {
      type = json['properties']['category'];
    }

    return MapboxPlace(
      name: json['text'] ?? '',
      fullAddress: json['place_name'] ?? '',
      lat: coordinates[1].toDouble(),
      lng: coordinates[0].toDouble(),
      placeType: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      'fullAddress': fullAddress,
      'lat': lat,
      'lng': lng,
      'placeType': placeType,
    };
  }

  factory MapboxPlace.fromFirestore(Map<String, dynamic> data) {
    return MapboxPlace(
      name: data['name'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
      lat: data['lat']?.toDouble() ?? 0.0,
      lng: data['lng']?.toDouble() ?? 0.0,
      placeType: data['placeType'],
    );
  }
}
