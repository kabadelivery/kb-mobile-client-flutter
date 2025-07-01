import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/order/delivery_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/tarif/tarif_entity.dart';
import 'package:flutter/foundation.dart';

import '../../Enums/deliveryStatus.dart';
import '../../domain/order/status_history_entry.dart';

class Delivery extends DeliveryEntity {
   String id;
   String? userId;
   String? buyerId;
   String? kabaUserId;
   String? packageName;
   String? trackingCode;
   double? declaredValue;
   String? recipientName;
   String? buyerPhoneNumber;
   int? shippingMode;
  String? status;
   String? currentStatus;
   bool? homeDelivery;
   double? estimatedWeight;
   String? collectionOffice;
   String? destinationOffice;
   String? addressText;
   String? notes;
   String? cancellationReason;
   String? purchaseProofImage;
   String? productImage;
   List<StatusHistoryEntry>? statusHistory;
   DateTime? createdAt;
   DateTime? updatedAt;
  Delivery({
    required this.id,
    this.userId,
    this.buyerId,
    this.kabaUserId,
    required this.packageName,
    required this.trackingCode,
    required this.declaredValue,
    required this.recipientName,
    required this.buyerPhoneNumber,
    required this.shippingMode,
    required this.status,
    this.currentStatus,
    required this.homeDelivery,
    required this.estimatedWeight,
    required this.collectionOffice,
    required this.destinationOffice,
    this.addressText,
    this.notes,
    this.cancellationReason,
    this.purchaseProofImage,
    this.productImage,
    this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  }):super(
    id: id,
    userId: userId,
    buyerId: buyerId,
    kabaUserId: kabaUserId,
    packageName: packageName,
    trackingCode: trackingCode,
    declaredValue: declaredValue,
    recipientName: recipientName,
    buyerPhoneNumber: buyerPhoneNumber,
    shippingMode: shippingMode,
    status: status,
    currentStatus: currentStatus,
    homeDelivery: homeDelivery,
    estimatedWeight: estimatedWeight,
    collectionOffice: collectionOffice,
    destinationOffice: destinationOffice,
    addressText: addressText,
    notes: notes,
    cancellationReason: cancellationReason,
    purchaseProofImage: purchaseProofImage,
    productImage: productImage,
    statusHistory: statusHistory,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      userId: json['userId'],
      buyerId: json['buyerId'],
      kabaUserId: json['kabaUserId'],
      packageName: json['packageName'],
      trackingCode: json['trackingCode'],
      declaredValue: (json['declaredValue'] as num).toDouble(),
      recipientName: json['recipientName'],
      buyerPhoneNumber: json['buyerPhoneNumber'],
      shippingMode: json['shippingMode']=="AVION"?Tariftype.plane.value:Tariftype.boat.value,
      status: json['status'],
      currentStatus: json['currentStatus'] != null
          ? json['currentStatus']
          : null,
      homeDelivery: json['homeDelivery'],
      estimatedWeight: (json['estimatedWeight'] as num).toDouble(),
      collectionOffice: json['collectionOffice'],
      destinationOffice: json['destinationOffice'],
      addressText: json['addressText'],
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      purchaseProofImage: json['purchaseProofImage'],
      productImage: json['productImage'],
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List)
          .map((e) => StatusHistoryEntry.fromJson(e))
          .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'buyerId': buyerId,
      'kabaUserId': kabaUserId,
      'packageName': packageName,
      'trackingCode': trackingCode,
      'declaredValue': declaredValue,
      'recipientName': recipientName,
      'buyerPhoneNumber': buyerPhoneNumber,
      'shippingMode': shippingMode == Tariftype.plane.value ? "AVION" : "BATEAU",
      'status': status,
      'currentStatus': currentStatus,
      'homeDelivery': homeDelivery,
      'estimatedWeight': estimatedWeight,
      'collectionOffice': collectionOffice,
      'destinationOffice': destinationOffice,
      'addressText': addressText,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'purchaseProofImage': purchaseProofImage,
      'productImage': productImage,
      'statusHistory':
          statusHistory?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  static Delivery decoy() {
    return Delivery(
      id: '1',
      userId: 'user-xyz',
      buyerId: 'buyer-abc',
      kabaUserId: 'kaba-789',
      packageName: 'Test Package',
      trackingCode: 'TRACK-XYZ-123',
      declaredValue: 250.75,
      recipientName: 'Jane Doe',
      buyerPhoneNumber: '+1000000000',
      shippingMode: Tariftype.boat.value, // or Tariftype.plane.value
      status: 'COLLECTED',
      currentStatus: 'Departed from collection office',
      homeDelivery: true,
      estimatedWeight: 3.2,
      collectionOffice: 'Central Hub',
      destinationOffice: 'Regional Center',
      addressText: '456 Test Lane',
      notes: 'Fragile, handle with care',
      cancellationReason: "Colis trop lourd",
      purchaseProofImage: 'https://example.com/mock-purchase-proof.jpg',
      productImage: 'https://example.com/mock-product.jpg',
      statusHistory: [
        StatusHistoryEntry(
          id: 'status-001',
          deliveryRequestId: 'test-delivery-001',
          status: 0, // e.g., "created"
          createdAt: DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          location: 'Warehouse A',
          notes: 'Package registered',
          performedBy: 'System',
        ),
        StatusHistoryEntry(
          id: 'status-002',
          deliveryRequestId: 'test-delivery-001',
          status: 1, // e.g., "in transit"
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          location: 'Collection Center',
          notes: 'Left origin facility',
          performedBy: 'Agent A',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    );
  }

}
