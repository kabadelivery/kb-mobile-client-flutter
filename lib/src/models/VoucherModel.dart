import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:flutter/foundation.dart';


class VoucherModel {

  var VOUCHER_category_FOOD = 1999, VOUCHER_category_DELIVERYFEES = 1998, VOUCHER_category_ALL = 1997;

  int id;
  String restaurant_name;
  String details;
  int value;
  int state; //
  int type; // type,
  int category; // category, food, delivery, category
  List<RestaurantFoodModel> products;
//  List<int> restaurant_id;
  RestaurantModel restaurant_entity;
  int use_count; // who's use count , total or mine
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

  /*"id":8,
  "name":"First Voucher for Ulrich",
  "category":1,
  "type":1,
  "max_persons":3690,
  "value":20,
  "use_count":2,
  "restaurant_id":3,
  "restaurant_entity":{
  "id":3,
  "name":"Mami"
  },
  "products":[],
  "start_date":"1592611200",
  "end_date":"1593475200",
  "can_self_subscribe":1,
  "enabled":1,
  "is_rewarded":0,
  "reward_on_food":0,
  "reward_category":null,
  "reward_cash_value":null,
  "reward_percentage_value":null,
  "subscription_code":"UL-01",
  "qr_code":"aa92f142629bd6bfe091f820d6ffeV",
  "tag":null,
  "created_at":"1593110001",
  "updated_at":"1593110001",
  "state":1*/

  /*int id;
  String restaurant_name;
  String details;
  String value;
  int state; //
  int type; // type,
  int category; // category, food, delivery, category
  List<int> restaurant_id;
  int use_count; // who's use count , total or mine
  String subscription_code;
  String qr_code;
  int start_date, end_date; // timestamp
  String tag;*/

  VoucherModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    restaurant_name = json['restaurant_name'];
    type = json['type'];
//    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    category = json['category'];
    try {
      if (json['restaurant_id'] != null && json['restaurant_entity'] != null &&
          json['restaurant_entity'] != [])
        restaurant_entity = RestaurantModel(id: json['restaurant_entity']['id'],
            name: json['restaurant_entity']['name']);
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
//    if (restaurant_id == null || restaurant_id?.length == 0) {
//      return null;
//    }
    // send the appended restaurant names or so.
    return restaurant_entity?.name;
  }


}