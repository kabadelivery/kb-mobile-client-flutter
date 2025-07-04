class StatusHistoryEntry{
  final String id;
  final String deliveryRequestId;
  final String status;
  final String createdAt;
  final String location;
  final String? notes;
  final String performedBy;

  StatusHistoryEntry({
    required this.id,
    required this.deliveryRequestId,
    required this.status,
    required this.createdAt,
    required this.location,
    this.notes,
    required this.performedBy,
  });
  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      id: json['id']??"",
      deliveryRequestId: json['deliveryRequestId']??"",
      status: json['status']??"PENDING",
      createdAt: json['createdAt']??"",
      location: json['location']??"",
      notes: json['notes']??"",
      performedBy: json['performedBy']??"",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryRequestId': deliveryRequestId,
      'status': status,
      'createdAt': createdAt,
      'location': location,
      'notes': notes,
      'performedBy': performedBy,
    };
  }
}