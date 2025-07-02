import 'package:KABA/src/microservices/kaba_chine/domain/tarif/shipping_entity.dart';

class TarifEntity{
  String? id;
  int? mode;
  double? price;
  int? duration;
  String ?unit;
  ShippingEntity? route;
  String ? updatedAt;
  TarifEntity({
     this.mode,
     this.price,
     this.duration,
     this.unit,
     this.route,
     this.id,
     this.updatedAt,
  });
}