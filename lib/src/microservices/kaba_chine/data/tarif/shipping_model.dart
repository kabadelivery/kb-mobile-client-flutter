import 'package:KABA/src/microservices/kaba_chine/domain/tarif/shipping_entity.dart';

class ShippingModel extends ShippingEntity{
  ShippingModel({
    required String departure,
    required String destination,
  }):super(
    departure: departure,
    destination: destination,
  );
  factory ShippingModel.fromJson(Map<String, dynamic> json) {
    return ShippingModel(
      departure: json['departure'] as String,
      destination: json['destination'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'departure': departure,
      'destination': destination,
    };
  }

}