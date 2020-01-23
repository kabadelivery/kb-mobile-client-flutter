import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';


class OrderBillConfiguration {


  String order_price;
  String delivery_price;
  bool is_promo;
  int discount; // %

  /* you balance */
  String your_balance;
  bool can_postpay;
  bool can_prepay;

  OrderBillConfiguration({this.order_price, this.delivery_price, this.is_promo, this.discount, this.your_balance, this.can_postpay, this.can_prepay});

  OrderBillConfiguration.fromJson(Map<String, dynamic> json) {
    order_price = json['order_price'];
    delivery_price = json['delivery_price'];
    is_promo = json['is_promo'];
    discount = json['discount'];
    your_balance = json['your_balance'];
    can_postpay = json['can_postpay'];
    can_prepay = json['can_prepay'];
  }

  Map toJson () => {
    "order_price" : order_price,
    "delivery_price" : delivery_price,
    "is_promo" : is_promo,
    "discount" : discount,
    "your_balance" : your_balance,
    "can_postpay" : can_postpay,
    "can_prepay" : can_prepay,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  static OrderBillConfiguration fake() {

    OrderBillConfiguration p = OrderBillConfiguration();
    p.order_price = "4500";
    p.delivery_price = "1000";
    p.is_promo = true;
    p.discount = 30;
    p.your_balance = "10000";
    p.can_prepay = true;
    p.can_postpay = true;
    return p;
  }

} 
