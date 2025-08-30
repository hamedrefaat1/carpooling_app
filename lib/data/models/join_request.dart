class JoinRequest {
  final String id;
  final String riderId;
  final String ridername;
  final String riderPhoneNumber;
  final Map<String, dynamic> riderLocation;
  final String status;
  final DateTime requsetedAt;
  final DateTime? responsedAt;

  JoinRequest({
    required this.id,
    required this.riderId,
    required this.ridername,
    required this.riderPhoneNumber,
    required this.riderLocation,
    required this.status,
    required this.requsetedAt,
    this.responsedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json, {required String documentId}) {
    return JoinRequest(
      id: json['id'] ?? '',
      riderId: json['riderId'] ?? '',
      ridername: json['ridername'] ?? '',
      riderPhoneNumber: json['riderPhoneNumber'] ?? '',
      riderLocation: json['riderLocation'] ?? {},
      status: json['status'] ?? 'pending',
      requsetedAt: json["requestedAt"]?.toDate() ?? DateTime.now(),
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
      'requestedAt': requsetedAt,
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
      ridername: ridername,
      riderPhoneNumber: riderPhoneNumber ?? this.riderPhoneNumber,
      riderLocation: riderLocation ?? this.riderLocation,
      status: status ?? this.status,
      requsetedAt: requestedAt ?? requsetedAt,
      responsedAt: respondedAt ?? responsedAt,
    );
  }
}
