import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';


class OrderBillConfiguration {

  int promotion_pricing;
  int command_pricing;
  int account_balance;
  String shipping_pricing;
  int total_pricing;
  String promotion_shipping_pricing;
  String remise;
  bool out_of_range;
  bool pay_at_delivery;
  bool prepayed;
  int trustful;
  String max_pay;
  int cooking_time;
  int distance;


  static OrderBillConfiguration fake() {
    OrderBillConfiguration p = OrderBillConfiguration();
    p.command_pricing = 4500;
    p.shipping_pricing = "1000";
    p.promotion_pricing = 3000;
    p.remise = "30";
    p.account_balance = 4000;
    p.prepayed = true;
    p.total_pricing = 3400;
    p.pay_at_delivery = true;
    p.trustful = 0;
    p.distance = 30;
    p.max_pay = "20000";
    p.cooking_time = 26;
    p.promotion_shipping_pricing = "400";
    return p;
  }


//      {
//    "error": 0,
//    "message": "",
//    "data": {
//      "promotion_pricing": 4500,
//      "command_pricing": 4500,
//      "account_balance": 9110755,
//      "shipping_pricing": "600",
//      "total_pricing": 4980,
//      "promotion_shipping_pricing": "480",
//      "remise": "3",
//      "out_of_range": false,
//      "pay_at_delivery": true,
//      "prepayed": true,
//      "trustful": 1,
//      "max_pay": "12500",
//      "cooking_time": 30,
//      "distance": 4677
//    }
//    }

  OrderBillConfiguration({this.promotion_pricing, this.command_pricing, this.account_balance, this.shipping_pricing,
    this.total_pricing, this.promotion_shipping_pricing, this.remise, this.out_of_range, this.pay_at_delivery,
    this.prepayed, this.trustful, this.max_pay, this.cooking_time, this.distance});

  OrderBillConfiguration.fromJson(Map<String, dynamic> json) {
    promotion_pricing = json['promotion_pricing'];
    command_pricing = json['command_pricing'];
    account_balance = json['account_balance'];
  shipping_pricing = json['shipping_pricing'];
    total_pricing = json['total_pricing'];
    promotion_shipping_pricing = json['promotion_shipping_pricing'];
    remise = json['remise'];
    out_of_range = json['out_of_range'];
    pay_at_delivery = json['pay_at_delivery'];
    prepayed = json['prepayed'];
    trustful = json['trustful'];
    max_pay = json['max_pay'];
    cooking_time = json['cooking_time'];
    distance = json['distance'];
  }

  Map toJson () => {
    "promotion_pricing" : promotion_pricing,
    "command_pricing" : command_pricing,
    "account_balance" : account_balance,
    "shipping_pricing" : shipping_pricing,
    "total_pricing" : total_pricing,
    "promotion_shipping_pricing" : promotion_shipping_pricing,
    "remise" : remise,
    "out_of_range" : out_of_range,
    "pay_at_delivery" : pay_at_delivery,
    "prepayed" : prepayed,
    "trustful" : trustful,
    "max_pay" : max_pay,
    "cooking_time" : cooking_time,
    "distance" : distance,
  };

  @override
  String toString() {
    return toJson().toString();
  }

} 
