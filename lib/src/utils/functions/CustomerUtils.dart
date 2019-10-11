import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerConfig.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomerUtils {


  static getCustomer () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonCustomer = prefs.getString("_loginResponse");
    var obj = json.decode(jsonCustomer);
    CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
    String token = obj["data"]["payload"]["token"];
    customer.token = token;
    return customer;
  }


}