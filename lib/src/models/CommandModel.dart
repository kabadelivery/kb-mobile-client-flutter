import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/KabaShippingMan.dart';
import 'package:kaba_flutter/src/models/OrderItemModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';

class CommandModel {

  int id;
  int restaurant_id;
  int state;
  /* shipping address */
  DeliveryAddressModel shipping_address;
  RestaurantModel restaurant_entity;
  List<OrderItemModel> food_list;
  String total_pricing;
  String shipping_pricing;
  String last_update;
  KabaShippingMan livreur;
  bool is_payed_at_arrival = false;
  /* clée de la commande */
  String passphrase = "~";
  String infos;
  int reason;

  String promotion_shipping_pricing;
  String command_pricing;
  String price_command;
  String promotion_pricing;
  String remise;


  CommandModel({this.id, this.restaurant_id, this.state, this.shipping_address,
    this.restaurant_entity, this.food_list, this.total_pricing,
    this.shipping_pricing,this.promotion_pricing, this.promotion_shipping_pricing, this.command_pricing, this.price_command, this.remise,
    this.last_update, this.livreur,
    this.is_payed_at_arrival, this.passphrase, this.reason});

  CommandModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    restaurant_id = json['restaurant_id'];
    state = json['state'];
    total_pricing = "${json['total_pricing']}";
    shipping_pricing = "${json['shipping_pricing']}";
    promotion_shipping_pricing = "${json['promotion_shipping_pricing']}";
    promotion_pricing = "${json['promotion_pricing']}";
    command_pricing = "${json['command_pricing']}";
    price_command = "${json['price_command']}";
    remise = "${json['remise']}";
    last_update = "${json['last_update']}";
    is_payed_at_arrival = json['is_payed_at_arrival'];
    passphrase = json['passphrase'];
    reason = json['reason'];
    infos = json['infos'];


    if (json['livreur'] != null)
      livreur = KabaShippingMan.fromJson(json['livreur']);
    else
      livreur = null;

    shipping_address = DeliveryAddressModel.fromJson(json['shipping_address']);

    if (json['restaurant_entity'] != null)
      restaurant_entity = RestaurantModel.fromJson(json['restaurant_entity']);

    l = json["food_list"];
    food_list = l?.map((f) => OrderItemModel.fromJson(f))?.toList();
  }

  Map toJson () => {
    "id" : id,
    "restaurant_id" : restaurant_id,
    "state" : state,
    "shipping_address" : shipping_address.toJson(),
    "restaurant_entity" : restaurant_entity.toJson(),
    "food_list" : food_list,
    "total_pricing" : total_pricing,
    "shipping_pricing" : shipping_pricing,
    "promotion_shipping_pricing" : promotion_shipping_pricing,
    "promotion_pricing" : promotion_pricing,
    "command_pricing" : command_pricing,
    "price_command" : price_command,
    "remise" : remise,
    "last_update" : last_update,
    "livreur" : livreur.toJson(),
    "is_payed_at_arrival" : is_payed_at_arrival,
    "passphrase" : passphrase,
    "reason" : reason,
    "infos" : infos
  };

  @override
  String toString() {
    return toJson().toString();
  }

  static CommandModel fake () {
    CommandModel model = CommandModel();
    model.state = 3;
    model.food_list = List();
    for (int i = 0; i < 4; i++) {
      model.food_list.add(OrderItemModel());
    }
    return model;
  }

}


class COMMAND_STATE {
  static const int WAITING = 0, COOKING = 1, SHIPPING = 2, DELIVERED = 3, REJECTED = 4;
}
