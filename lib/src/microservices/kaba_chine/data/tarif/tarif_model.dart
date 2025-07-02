import 'package:KABA/src/microservices/kaba_chine/data/tarif/shipping_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/tarif/tarif_entity.dart';

class TarifModel extends TarifEntity{

  TarifModel({
    required String id,
    required int mode,
    required double price,
    required int duration,
    required String  unit,
    required ShippingModel route,
    required  String  updatedAt
  }):super(
    id: id,
    mode: mode,
    price: price,
    duration: duration,
    unit: unit,
    route: route,
    updatedAt: updatedAt,
  );
  factory TarifModel.fromJson(Map<String, dynamic> json) {
    return TarifModel(
      id: json['id'],
      mode: json['mode'],
      price: json['price'],
      duration: json['duration'],
      unit: json['unit'],
      route: ShippingModel.fromJson(json['route']),
      updatedAt: json['updatedAt'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode,
      'price': price,
      'duration': duration,
      'unit': unit,
      'route': ShippingModel(departure: route!.departure.toString(), destination: route!.destination.toString()).toJson(),
      'updatedAt': updatedAt,
    };
  }
}