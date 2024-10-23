import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:flutter/foundation.dart';

import '../xrint.dart';

class VoucherModel {
  int id;
  String restaurant_name;
  String trade_name;
  String details;
  int value;
  int state; //
  int type; // type, % or F discount
  int category; // category, food, delivery, category
  List<ShopProductModel> products;

//  ShopModel restaurant_entity;
  List<ShopModel> restaurants;
  int use_count; // how much time can i use the voucher
  int already_used_count;

  int total_used_count; // how much time can you use in total
  String subscription_code;
  String qr_code;
  String start_date, end_date; // timestamp
  String tag;
  String description;

  VoucherModel({
    this.id,
    this.details,
    this.value,
    this.state,
    this.type,
  });

  VoucherModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    trade_name = json['trade_name'];
    type = json['type'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    category = json['category'];
    try {
      if (json['restaurants'] != null || json['restaurants'] != []) {
        l = json["restaurants"];
        restaurants = l?.map((r) => ShopModel.fromJson(r))?.toList();
      }
    } catch (_) {
      xrint(_);
    }
    use_count = json['use_count'];
    already_used_count = json["already_used_count"];
    subscription_code = json['subscription_code'];
    qr_code = json['qr_code'];
    tag = json['tag'];
    start_date = "${json['start_date']}";
    description = json['description'];

    if (json['products'] != null || json['products'] != []) {
      l = json["products"];
      products = l?.map((r) => ShopProductModel.fromJson(r))?.toList();
    }

    end_date = "${json['end_date']}";
  }

  Map toJson() => {
        "type": (type as int),
        "details": details,
        "value": value,
        "already_used_count": already_used_count,
        "state": state,
        "type": type,
        'description': description
      };

  @override
  String toString() {
    return toJson().toString();
  }

  VoucherModel.randomRestaurant() : super() {
    /*
    imagine we want the promotion over specific foods,
     we need to choose them as well, and get them into the voucher
      */
    id = 100;
    restaurant_name = "CHILLILOCO";
    details = "";
    value = 1000;
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 1; // RESTAURANT
//    restaurant_id = [17];
    use_count = 10;
    subscription_code = "LOCODEC20";
    qr_code = "";
    start_date = "123454321";
    end_date = "123454321";
    tag = "";
    description = "i tell what you want to know";
  }

  VoucherModel.randomDelivery() : super() {
    id = 100;
    restaurant_name = "DELIVERY";
    details =
        "this voucher works for everyrestaurant"; // DEPENDS IF IT WORKS ONLY ON A RESTAURANT
    value = 10;
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 2; // DELIVERY
//    restaurant_id = [17]; // if specific || if -1, all restaurant, if array plenty restaurant, or single one restaurant, otherwise all restaurant
    use_count = 10; // how many times did i use them myself
    subscription_code = "FFURIOUS029"; // i want to subscribe, how do i do it
    qr_code = ""; // code qr
    start_date = "123454321";
    end_date = "123454321";
    tag = "";
    description = "i tell what you want to know";
  }

  VoucherModel.randomBoth() : super() {
    /*
      discount on both, delivery fees and food fees
      */
    id = 100;
    restaurant_name = "CHILLILOCO&KABA";
    details = "";
    value = 1000;
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 3; // BOTH
    // add specificity for foods...
//    restaurant_id = []; // all -1, specific [17,89]
    use_count = 10;
    subscription_code = "KABA0029";
    qr_code = "";
    start_date = "123454321";
    end_date = "123454321";
    tag = "";
    description = "i tell what you want to know";
  }

  getRestaurantsName() {
    // send the appended restaurant names or so.
    if (this.restaurants?.length == null)
      return null;
    else if (this.restaurants?.length == 1) {
      return this.restaurants[0]?.name;
    } else {
      return "-1";
    }
  }
}
