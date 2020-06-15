import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:flutter/foundation.dart';


class VoucherModel {

  var VOUCHER_CATEGORY_FOOD = 1999, VOUCHER_CATEGORY_DELIVERYFEES = 1998, VOUCHER_CATEGORY_ALL = 1997;

  int id;
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
  int ts_start, ts_end; // timestamp
  String tags;

//  int reward_type;
//  int reward_cash_value;
//  int reward_percentage_value;


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
//  private $rewardType; , is the reward giving on the food or a fixed amount
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
    type = json['type'];
    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
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
    value = "1000";
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 1; // RESTAURANT
    restaurant_id = [17];
    use_count = 10;
    subscription_code = "";
    qr_code = "";
    ts_start = 123454321;
    ts_end = 123454321;
    tags = "";
  }

  VoucherModel.randomDelivery() : super() {

    id = 100;
    restaurant_name = "ALL RESTAURANT";
    details = "this voucher works for everyrestaurant"; // DEPENDS IF IT WORKS ONLY ON A RESTAURANT
    value = "10";
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 2; // DELIVERY
    restaurant_id = [17]; // if specific || if -1, all restaurant, if array plenty restaurant, or single one restaurant, otherwise all restaurant
    use_count = 10; // how many times did i use them myself
    subscription_code = ""; // i want to subscribe, how do i do it
    qr_code = ""; // code qr
    ts_start = 123454321;
    ts_end = 123454321;
    tags = "";
  }

  VoucherModel.randomBoth() : super() {

    /*
      discount on both, delivery fees and food fees
      */
    id = 100;
    restaurant_name = "CHILLILOCO";
    details = "";
    value = "1000";
    state = 1; // no deleted
    type = 1; // percentage or value
    category = 3; // BOTH
    // add specificity for foods...
    restaurant_id = []; // all -1, specific [17,89]
    use_count = 10;
    subscription_code = "";
    qr_code = "";
    ts_start = 123454321;
    ts_end = 123454321;
    tags = "";
  }


  getRestaurantsName() {
    if (restaurant_id == null || restaurant_id?.length == 0) {
      return null;
    }
    // send the appended restaurant names or so.
      return restaurant_name;
  }


}