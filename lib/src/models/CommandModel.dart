import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
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
    int reason;

    CommandModel(this.id, this.restaurant_id, this.state, this.shipping_address,
        this.restaurant_entity, this.food_list, this.total_pricing,
        this.shipping_pricing, this.last_update, this.livreur,
        this.is_payed_at_arrival, this.passphrase, this.reason);

    CommandModel.fromJson(Map<String, dynamic> json) {

        id = json['id'];
        restaurant_id = json['restaurant_id'];
        state = json['state'];
        shipping_address = json['shipping_address'];
        restaurant_entity = json['restaurant_entity'];
        food_list = json['food_list'];
        total_pricing = json['total_pricing'];
        shipping_pricing = json['shipping_pricing'];
        last_update = json['last_update'];
        livreur = json['livreur'];
        is_payed_at_arrival = json['is_payed_at_arrival'];
        passphrase = json['passphrase'];
        reason = json['reason'];
    }

    Map toJson () => {
        "id" : (id as int),
        "restaurant_id" : restaurant_id,
        "state" : state,
        "shipping_address" : shipping_address,
        "restaurant_entity" : restaurant_entity,
        "food_list" : food_list,
        "total_pricing" : total_pricing,
        "shipping_pricing" : shipping_pricing,
        "last_update" : last_update,
        "livreur" : livreur,
        "is_payed_at_arrival" : is_payed_at_arrival,
        "passphrase" : passphrase,
        "reason" : reason,
    };

    @override
    String toString() {
        return toJson().toString();
    }



}
