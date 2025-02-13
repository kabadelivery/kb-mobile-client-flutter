import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/KabaPointConfigurationModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/DeliveryTimeFrameModel.dart';
import 'package:KABA/src/models/ShopModel.dart';


class OrderBillConfiguration {

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

  int can_preorder;
  String discount;
  int open_type = -1;
  String working_hour = "";
  String reason;
  List<DeliveryTimeFrameModel> deliveryFrames;

  bool isBillBuilt = false;
  bool hasCheckedOpen = false;

  int total_preorder_pricing;
  //
  KabaPointConfigurationModel kaba_point;

  // eligible voucher
  List<VoucherModel> eligible_vouchers;

  Map<String,dynamic> additional_fees;
  int  additional_fees_total_price;

  static OrderBillConfiguration fake() {
    OrderBillConfiguration p = OrderBillConfiguration.none();

    p.command_pricing =  4500; // "4500";
    p.shipping_pricing = 1000; // "1000";
    p.total_pricing = 5500; "5500";

    p.promotion_pricing = 3000; //"3000";
    p.promotion_shipping_pricing = 400; // "400";
    p.additional_fees={
      "COMMISSION_FEE": 360,
      "PACKAGING_FEE": 200,
      "WEATHER_FEE": 0,
      "NIGHT_FEE": 10,
      "PUBLIC_HOLYDAY_FEE": 100,
      "WEEKEND_FEE": 0
    };
    p.additional_fees_total_price=670;
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
    this.max_pay, this.cooking_time, this.can_preorder, this.discount, this.eligible_vouchers,
    this.open_type, this.working_hour, this.reason, this.deliveryFrames, this.isBillBuilt, this.kaba_point,
    this.additional_fees,this.additional_fees_total_price});


  OrderBillConfiguration.fromJson(Map<String, dynamic> json) {
    promotion_pricing =  json['promotion_pricing'];
    command_pricing = json['command_pricing'];
    account_balance = json['account_balance'];
    shipping_pricing = json['shipping_pricing'];
    total_pricing = json['total_pricing'];
    total_normal_pricing = json['total_normal_pricing'];
    promotion_shipping_pricing = json['promotion_shipping_pricing'];
    remise = json['remise'] is int ? json['remise'] : int.parse(json['remise'].toString());
    out_of_range = json['out_of_range'];
    pay_at_delivery = json['pay_at_delivery'];
    prepayed = json['prepayed'];
    trustful = json['trustful'];
    max_pay = json['max_pay'];
    kaba_point = KabaPointConfigurationModel.fromMap(json["kaba_point"]);
    cooking_time = json['cooking_time'];
    additional_fees = json['additional_fees'];
    additional_fees_total_price = json['additional_fees_total_price'];
    // eligible voucher
      l = json["eligible_vouchers"];
    eligible_vouchers = l?.map((voucher_model) => VoucherModel.fromJson(voucher_model))?.toList();

  }

  Map toJson () => {
    "promotion_pricing" : promotion_pricing,
    "command_pricing" : command_pricing,
    "account_balance" : account_balance,
    "shipping_pricing" : shipping_pricing,
    "total_normal_pricing" : total_normal_pricing,
    "total_pricing" : total_pricing,
    "promotion_shipping_pricing" : promotion_shipping_pricing,
    "remise" : remise,
    "out_of_range" : out_of_range,
    "pay_at_delivery" : pay_at_delivery,
    "prepayed" : prepayed,
    "trustful" : trustful,
    "max_pay" : max_pay,
    "cooking_time" : cooking_time,
    "kaba_point": kaba_point?.toMap(),
    "additional_fees":additional_fees,
    "additional_fees_total_price":additional_fees_total_price,
  };

  @override
  String toString() {
    return toJson().toString();
  }

} 
