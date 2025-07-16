import '../../domain/order/payment_info_entity.dart';

class PaymentInfoModel extends PaymentInfoEntity {
  const PaymentInfoModel({
    required int shippingFee,
    required int totalPaid,
    required int remaining,
    required int paidPercent,
    required int minPercent,
  }) : super(
    shippingFee: shippingFee,
    totalPaid: totalPaid,
    remaining: remaining,
    paidPercent: paidPercent,
    minPercent: minPercent,
  );

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      shippingFee: json['shippingFee'],
      totalPaid: json['totalPaid'],
      remaining: json['remaining'],
      paidPercent: json['paidPercent'],
      minPercent: json['minPercent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingFee': shippingFee,
      'totalPaid': totalPaid,
      'remaining': remaining,
      'paidPercent': paidPercent,
      'minPercent': minPercent,
    };
  }
}
