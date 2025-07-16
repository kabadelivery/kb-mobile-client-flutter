import '../../domain/order/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required String id,
    required String deliveryRequestId,
    required String kabaUserId,
    required int amount,
    required String paymentMethod,
    required String currency,
    required DateTime createdAt,
    required String paymentStatus,
    required String txReference,
  }) : super(
    id: id,
    deliveryRequestId: deliveryRequestId,
    kabaUserId: kabaUserId,
    amount: amount,
    paymentMethod: paymentMethod,
    currency: currency,
    createdAt: createdAt,
    paymentStatus: paymentStatus,
    txReference: txReference,
  );

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      deliveryRequestId: json['deliveryRequestId'],
      kabaUserId: json['kabaUserId'],
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
      paymentStatus: json['paymentStatus'],
      txReference: json['txReference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryRequestId': deliveryRequestId,
      'kabaUserId': kabaUserId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'paymentStatus': paymentStatus,
      'txReference': txReference,
    };
  }
}
