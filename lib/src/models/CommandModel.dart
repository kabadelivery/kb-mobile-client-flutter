import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/KabaShippingMan.dart';
import 'package:kaba_flutter/src/models/OrderItemModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';

import 'DeliveryTimeFrameModel.dart';

class CommandModel {

  int id;
  int restaurant_id;
  int state;
  /* shipping address */
  DeliveryAddressModel shipping_address;
  RestaurantModel restaurant_entity;
  List<OrderItemModel> food_list;
  String last_update;
  KabaShippingMan livreur;
  bool is_payed_at_arrival = false;
  /* clée de la commande */
  String passphrase = "~";
  String infos;
  int reason;


  String remise;

  // normal one
  int total_pricing;
  int shipping_pricing;
  int food_pricing;

  // preorder case
  int preorder_total_pricing;
  int preorder_shipping_pricing;
  int preorder_food_pricing;

  // promotion case
  int promotion_total_pricing;
  int promotion_shipping_pricing;
  int promotion_food_pricing;

  // differents cases
  int is_preorder = 0;
  int is_promotion = 0;


  String preorder_discount;
  int preorder = 0;///////
  DeliveryTimeFrameModel preorder_hour;

  int rating;
  String comment;


  CommandModel({this.id, this.restaurant_id, this.state,
    this.shipping_address, this.restaurant_entity, this.food_list,
    this.last_update, this.livreur, this.is_payed_at_arrival, this.passphrase,
    this.infos, this.reason, this.remise, this.total_pricing,
    this.shipping_pricing, this.food_pricing, this.preorder_total_pricing,
    this.preorder_shipping_pricing, this.preorder_food_pricing,
    this.promotion_total_pricing, this.promotion_shipping_pricing,
    this.promotion_food_pricing, this.is_preorder, this.is_promotion,
    this.preorder_discount, this.preorder, this.preorder_hour});


  CommandModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    restaurant_id = json['restaurant_id'];
    state = json['state'];
    total_pricing = json['total_pricing'];
    remise = "${json['remise']}";
    last_update = "${json['last_update']}";
    is_payed_at_arrival = json['is_payed_at_arrival'];
    passphrase = json['passphrase'];
    reason = json['reason'];
    infos = json['infos'];
    rating = json["rating"];
    comment = json["comment"];

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

    // normal one
    total_pricing = json["total_pricing"];
    shipping_pricing = json["shipping_pricing"];
    food_pricing = json["food_pricing"];

    // preorder case
    preorder_total_pricing = json["preorder_total_pricing"];
    preorder_shipping_pricing = json["preorder_shipping_pricing"];
    preorder_food_pricing = json["preorder_food_pricing"];

    // promotion case
    promotion_total_pricing = json["promotion_total_pricing"];
    promotion_shipping_pricing = json["promotion_shipping_pricing"];
    promotion_food_pricing = json["promotion_food_pricing"];

    // differents cases
    is_preorder = json["is_preorder"];
    is_promotion = json["is_promotion"];
    preorder_discount = "${json["preorder_discount"]}";;
    preorder = json["preorder"];

    if (json["preorder_hour"] != null )
      preorder_hour = DeliveryTimeFrameModel.fromJson(json['preorder_hour']);

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
    "remise" : remise,
    "last_update" : last_update,
    "livreur" : livreur.toJson(),
    "is_payed_at_arrival" : is_payed_at_arrival,
    "passphrase" : passphrase,
    "reason" : reason,
    "infos" : infos,
    "rating" : rating,
    "comment" : comment
  };



  CommandModel.LitefromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['state'];
    last_update = "${json['last_update']}";
  }

  Map LitetoJson() => {
    "id" : id,
    "state" : state,
    "last_update" : last_update,
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
