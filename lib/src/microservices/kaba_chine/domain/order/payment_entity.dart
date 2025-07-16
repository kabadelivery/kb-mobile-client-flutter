class PaymentEntity {
  final String id;
  final String deliveryRequestId;
  final String kabaUserId;
  final int amount;
  final String paymentMethod;
  final String currency;
  final DateTime createdAt;
  final String paymentStatus;
  final String txReference;

  const PaymentEntity({
    required this.id,
    required this.deliveryRequestId,
    required this.kabaUserId,
    required this.amount,
    required this.paymentMethod,
    required this.currency,
    required this.createdAt,
    required this.paymentStatus,
    required this.txReference,
  });
}
