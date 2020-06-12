import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/RestaurantModel.dart';


class VoucherModel {

  int id;
  String details;
  String value;
  int state;
  int type; // 1 -> in, -1 -> out
  String created_at;


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
    this.created_at}); // timestamp

  VoucherModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    created_at = json['created_at'];
  }

  Map toJson () => {
    "type" : (type as int),
    "details" : details,
    "value" : value,
    "state" : state,
    "type" : type,
    "created_at" : created_at,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}