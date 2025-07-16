
import 'package:KABA/src/microservices/kaba_chine/data/order/payment_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/order/status_history_entry.dart';

import '../../data/order/payment_info_model.dart';

class DeliveryEntity {
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
  String? addressId;
  String? afalikaBatchId;
  String? afalikaTrackingId;
  String? afalikaPackageId;
  String? afalikaTrackingCode;
  dynamic address;
  DateTime? estimatedArrival;
  List<PaymentModel>? payments;
  PaymentInfoModel? paymentInfo;

  DeliveryEntity({
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
    this.addressId,
    this.afalikaBatchId,
    this.afalikaTrackingId,
    this.afalikaPackageId,
    this.afalikaTrackingCode,
    this.address,
    this.estimatedArrival,
    this.payments,
    this.paymentInfo

  });

}