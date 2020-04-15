import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/KabaShippingMan.dart';
import 'package:kaba_flutter/src/models/OrderItemModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';

class DeliveryTimeFrameModel {

  int id; // id of it
  String start; // what time start delivery
  String end;

  DeliveryTimeFrameModel({this.id, this.start, this.end});

  DeliveryTimeFrameModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
  }

  Map toJson () =>
      {
        "id": id,
        "start": start,
        "end": end,
      };

}