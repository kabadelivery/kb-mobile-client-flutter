import 'DeliveryUpdateInfo.dart';

class DeliveryStatusUpdate {
  final String id;
  final String deliveryId;
  final String kabaUserId;
  final String oldStatus;
  final String newStatus;
  final bool isRead;
  final DateTime timestamp;
  final String? notes;
  final DeliveryUpdateInfo delivery;

  DeliveryStatusUpdate({
    required this.id,
    required this.deliveryId,
    required this.kabaUserId,
    required this.oldStatus,
    required this.newStatus,
    required this.isRead,
    required this.timestamp,
    this.notes,
    required this.delivery,
  });

  factory DeliveryStatusUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusUpdate(
      id: json['id'],
      deliveryId: json['deliveryId'],
      kabaUserId: json['kabaUserId'],
      oldStatus: json['oldStatus'],
      newStatus: json['newStatus'],
      isRead: json['isRead'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      delivery: DeliveryUpdateInfo.fromJson(json['delivery']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryId': deliveryId,
      'kabaUserId': kabaUserId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'delivery': delivery.toJson(),
    };
  }
}


