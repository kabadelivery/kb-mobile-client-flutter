import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/DeliveryTimeFrameModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';


class OrderBillConfiguration {

  /*
  *      price_delivery = data.get("shipping_pricing").getAsString(); // normal shipping price
                    promotion_shipping_pricing = data.get("promotion_shipping_pricing").getAsString(); // promotion shipping price
                    promotion_pricing =  data.get("promotion_pricing").getAsString(); // promotion food pricing
                    price_command = data.get("command_pricing").getAsString(); // normal food pricing
                    remise = data.get("remise").getAsString(); //
                    price_net_to_pay = data.get("total_pricing").getAsString(); // total pricing -
                    // total normal pricing
                    price_normal_to_pay = data.get("total_normal_pricing").getAsString(); // total pricing -
                    solde = ""+data.get("account_balance").getAsInt(); // solde of client
                    /* check the allowed transactions methods */
                    try {
                        out_of_range = data.get("out_of_range").getAsBoolean();
                        is_postpayed_allowed = data.get("pay_at_delivery").getAsBoolean();
                        is_prepayed_allowed = data.get("prepayed").getAsBoolean();
                        /* check this according to my own trustful value and the total price to pay */
                        trustful = data.get("trustful").getAsInt();
//                        boolean trustful = data.get("trustful").getAsBoolean();
                        mp = data.get("max_pay").getAsString();
                        estimation_cooking_time = data.get("cooking_time").getAsInt();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
  *
  * */

// NORMAL

//  String shipping_pricing;
//  String promotion_shipping_pricing;
//  String promotion_pricing; // promotion food pricing.
//  String command_pricing; // command pricing
//  String remise;
//  String total_pricing; // total current pricing
//  String total_normal_pricing; // total normal pricing to set difference between this and promotion time

  int shipping_pricing;
  int promotion_shipping_pricing;
  int promotion_pricing; // promotion food pricing.
  int command_pricing; // command pricing
  int remise;
  int total_pricing; // total current pricing
  int total_normal_pricing; // total normal pricing to set difference between this and promotion time


  int account_balance;
  bool out_of_range = true;
  bool pay_at_delivery = false;
  bool prepayed = false;
  int trustful;
  int max_pay;
  int cooking_time;

//  int promotion_pricing;
//  int command_pricing;
//  int account_balance;
//  String shipping_pricing;
//  int total_pricing;
//  String promotion_shipping_pricing;
//  String remise;
//  bool out_of_range;
//  bool pay_at_delivery;
//  bool prepayed;
//  int trustful;
//  String max_pay;
//  int cooking_time;
//  int distance;


  int can_preorder;
  String discount;
  int open_type = -1;
  String reason;
List<DeliveryTimeFrameModel> deliveryFrames;

  bool isBillBuilt = false;
  bool hasCheckedOpen = false;

  int total_preorder_pricing;
  // get delivery frames


  static OrderBillConfiguration fake() {
    OrderBillConfiguration p = OrderBillConfiguration.none();

    p.command_pricing =  4500; // "4500";
    p.shipping_pricing = 1000; // "1000";
    p.total_pricing = 5500; "5500";

    p.promotion_pricing = 3000; //"3000";
    p.promotion_shipping_pricing = 400; // "400";

    p.remise = 30; // "30";
    p.account_balance = 4000;

    p.prepayed = true;
    p.pay_at_delivery = true;


    p.trustful = 0;
    p.max_pay = 20000;
    p.cooking_time = 46;

    p.isBillBuilt = false;

    p.can_preorder = 1;
    p.discount = "30";
    p.open_type = 1;
    p.reason = "Nous sommes desole de cela.";

    return p;
  }

  OrderBillConfiguration.none();

  OrderBillConfiguration({this.shipping_pricing, this.promotion_shipping_pricing,
    this.promotion_pricing, this.total_preorder_pricing, this.command_pricing, this.remise,
    this.total_pricing, this.total_normal_pricing, this.account_balance,
    this.out_of_range, this.pay_at_delivery, this.prepayed, this.trustful,
    this.max_pay, this.cooking_time, this.can_preorder, this.discount,
    this.open_type, this.reason, this.deliveryFrames, this.isBillBuilt});


  OrderBillConfiguration.fromJson(Map<String, dynamic> json) {
    promotion_pricing =  json['promotion_pricing'];
    command_pricing = json['command_pricing'];
    account_balance = json['account_balance'];
    shipping_pricing = json['shipping_pricing'];
    total_pricing = json['total_pricing'];
    promotion_shipping_pricing = json['promotion_shipping_pricing'];
    remise = int.parse(json['remise']);
    out_of_range = json['out_of_range'];
    pay_at_delivery = json['pay_at_delivery'];
    prepayed = json['prepayed'];
    trustful = json['trustful'];
    max_pay = json['max_pay'];
    cooking_time = json['cooking_time'];
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
  };

  @override
  String toString() {
    return toJson().toString();
  }

} 
