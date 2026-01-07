import 'address.dart';

enum DeliveryTimeType { instant, scheduled }
enum PaymentMode { cashOnDelivery, walletNow, walletOnPickup }
enum PayerType { sender, receiver }

class PackageDelivery {
  Address departure;
  Address arrival;

  int deliveryFee;
  String phone;

  DeliveryTimeType timeType;
  DateTime? scheduledAt;

  bool isShop;
  String description;
  List<String> photos;

  bool collectAmount;
  int? amountToCollect;
  PayerType payer;
  PaymentMode paymentMode;

  PackageDelivery({
    required this.departure,
    required this.arrival,
    this.deliveryFee = 2500,
    this.phone = "",
    this.timeType = DeliveryTimeType.instant,
    this.isShop = false,
    this.description = "",
    this.photos = const [],
    this.collectAmount = false,
    this.payer = PayerType.receiver,
    this.paymentMode = PaymentMode.cashOnDelivery,
  });

  Map<String, dynamic> toJson() => {
    "departure": departure.toJson(),
    "arrival": arrival.toJson(),
    "deliveryFee": deliveryFee,
    "phone": phone,
    "timeType": timeType.name,
    "scheduledAt": scheduledAt?.toIso8601String(),
    "isShop": isShop,
    "description": description,
    "photos": photos,
    "payment": {
      "collectAmount": collectAmount,
      "amountToCollect": amountToCollect,
      "payer": payer.name,
      "mode": paymentMode.name,
    }
  };
}
