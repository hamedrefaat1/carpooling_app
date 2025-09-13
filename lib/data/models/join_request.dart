class JoinRequest {
  final String id;
  final String riderId;
  final String ridername;
  final String riderPhoneNumber;
  final Map<String, dynamic> riderLocation;
  final String status;
  final DateTime requestedAt; // fixed typo: requsetedAt
  final DateTime? responsedAt;

  JoinRequest({
    required this.id,
    required this.riderId,
    required this.ridername,
    required this.riderPhoneNumber,
    required this.riderLocation,
    required this.status,
    required this.requestedAt, // fixed typo
    this.responsedAt,
  });

  // Fixed factory method - removed extra String id parameter
  factory JoinRequest.fromJson(Map<String, dynamic> json, {required String documentId}) {
    return JoinRequest(
      id: documentId, // use documentId instead of json['id']
      riderId: json['riderId'] ?? '',
      ridername: json['ridername'] ?? '',
      riderPhoneNumber: json['riderPhoneNumber'] ?? '',
      riderLocation: json['riderLocation'] ?? {},
      status: json['status'] ?? 'pending',
      requestedAt: json["requestedAt"]?.toDate() ?? DateTime.now(), // fixed typo
      responsedAt: json["responsedAt"]?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderId': riderId,
      'ridername': ridername,
      'riderPhoneNumber': riderPhoneNumber,
      'riderLocation': riderLocation,
      'status': status,
      'requestedAt': requestedAt, // fixed typo
      'responsedAt': responsedAt,
    };
  }

  JoinRequest copyWith({
    String? id,
    String? riderId,
    String? riderName,
    String? riderPhoneNumber,
    Map<String, dynamic>? riderLocation,
    String? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      ridername: riderName ?? this.ridername, 
      riderPhoneNumber: riderPhoneNumber ?? this.riderPhoneNumber,
      riderLocation: riderLocation ?? this.riderLocation,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt, 
      responsedAt: respondedAt ?? this.responsedAt,
    );
  }
}