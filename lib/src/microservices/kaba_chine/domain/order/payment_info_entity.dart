class PaymentInfoEntity {
  final int shippingFee;
  final int totalPaid;
  final int remaining;
  final int paidPercent;
  final int minPercent;

  const PaymentInfoEntity({
    required this.shippingFee,
    required this.totalPaid,
    required this.remaining,
    required this.paidPercent,
    required this.minPercent,
  });
}
