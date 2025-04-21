import 'package:flutter/foundation.dart';
import 'dart:core';

class TopUpConfigurationModel {

  // 0 -> not authorized, 1 -> authorized
  int? tmoney = 0;
  int? flooz = 0;
  int? visa = 0;
  int? mobile_fees = 0;
  int? visa_fees = 0;

  TopUpConfigurationModel({this.tmoney, this.flooz, this.visa, this.visa_fees, this.mobile_fees});

  TopUpConfigurationModel.fromJson(Map<String, dynamic> json) {

    tmoney = int.parse("${['tmoney']}");
    flooz = int.parse("${['flooz']}");
    visa = int.parse("${['visa']}");

    visa_fees = int.parse("${['visa_fees']}");
    mobile_fees = int.parse("${['mobile_fees']}");
  }

  Map toJson () => {
    "tmoney" : (tmoney as int),
    "flooz" : (flooz as int),
    "visa" : (visa as int),
    "visa_fees" : (visa_fees as int),
    "mobile_fees" : (mobile_fees as int)
  };

  @override
  String toString() {
    return toJson().toString();
  }

}