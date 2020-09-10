import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:flutter/foundation.dart';


class VoucherModel {

  var VOUCHER_category_FOOD = 1999, VOUCHER_category_DELIVERYFEES = 1998, VOUCHER_category_ALL = 1997;

  int id;
  String restaurant_name;
  String trade_name;
  String details;
  int value;
  int state; //
  int type; // type,
  int category; // category, food, delivery, category
  List<RestaurantFoodModel> products;
//  RestaurantModel restaurant_entity;
  List<RestaurantModel> restaurants;
  int use_count; // how much time have you used it already
  int total_used_count; // how much time can you use in total
  String subscription_code;
  String qr_code;
  String start_date, end_date; // timestamp
  String tag;

//  int reward_type;
//  int reward_cash_value;
//  int reward_percentage_value;

  // type -> LIVRAISON, REPAS, ALL
  // category -> POURCENTAGE OU VALEURE

//  private $id; , id of the voucher
//  private $name; , name of the voucher (for the admin)
//  private $type; type of the voucher, (ajouter les bons de consommation ou tu consommes et que ca reste a chaque fois)
//  private $category; ?
//  private $value; , value -1000F or -10%
//  private $maxPersons; , max personn that can subscribe to this voucher
//  private $restaurantId; , restaurant where this voucher can eventually used
//  private $products; , the products that concern the promotion
//  private $canSelfSubscribe=0; , can i share the voucher with somebody to share it
//  private $isRewarded=0; , is anybody getting money behind this voucher
//  private $rewardOnFood=0;
//  private $rewardtype; , is the reward giving on the food or a fixed amount
//  private $rewardCashValue;
//  private $rewardPercentageValue;
//  private $enabled; , enabled or disabled
//  private $useCount;
//  private $subscriptionCode;
//  private $qrCode;
//  private $startDate;
//  private $endDate;
//  private $tags;
//  private $createdAt;
//  private $updatedAt;


  VoucherModel({this.id, this.details, this.value, this.state, this.type,
  }); // timestamp


  VoucherModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];

//    if (json["restaurant_entity"] != null)
//      restaurant_name = RestaurantModel.fromJson(json['restaurant_entity']).name;

    trade_name = json['trade_name'];
    type = json['type'];
//    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    category = json['category'];
    try {
      if (json['restaurants'] != null || json['restaurants'] != []) {
        l = json["restaurants"];
        restaurants = l?.map((r) => RestaurantModel.fromJson(r))?.toList();
      }
      /*   if (json['restaurant_id'] != null && json['restaurant_entity'] != null &&
          json['restaurant_entity'] != [])
      restaurant_entity = RestaurantModel(id: json['restaurant_entity']['id'],
            name: json['restaurant_entity']['name']);*/
    } catch(_) {
      print(_);
    }
    use_count = json['use_count'];
    subscription_code = json['subscription_code'];
    qr_code = json['qr_code'];
    tag = json['tag'];
    start_date = json['start_date'];

    if (json['products'] != null || json['products'] != []) {
      l = json["products"];
      products = l?.map((r) => RestaurantFoodModel.fromJson(r))?.toList();
    }

    end_date = json['end_date'];
  }


  Map toJson () => {
    "type" : (type as int),
    "details" : details,
    "value" : value,
    "state" : state,
    "type" : type,
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
  }

  VoucherModel.randomDelivery() : super() {

    id = 100;
    restaurant_name = "DELIVERY";
    details = "this voucher works for everyrestaurant"; // DEPENDS IF IT WORKS ONLY ON A RESTAURANT
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
  }

  getRestaurantsName() {
    // send the appended restaurant names or so.
    if (this.restaurants?.length == null)
      return null;
    else if (this.restaurants?.length == 1){
      return this.restaurants[0]?.name;
    } else {
      return "-1";
    }
  }


}