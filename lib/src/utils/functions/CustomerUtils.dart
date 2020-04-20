import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomerUtils {

  static popBack(BuildContext context) {
    if (!Navigator.pop(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SplashPage(),
        ),
      );
    }
  }

  static persistTokenAndUserdata(String token, String loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("_loginResponse", loginResponse);
    /* no need to commit */
    /* expiration date in 3months */
    String expDate = DateTime.now().add(Duration(days: 90)).toIso8601String();
    prefs.setString("_login_expiration_date", expDate);
    print(expDate);
  }


  static Future<CustomerModel> getCustomer () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CustomerModel customer;
    try {
      String jsonCustomer = prefs.getString("_loginResponse");
      var obj = json.decode(jsonCustomer);
        customer = CustomerModel.fromJson(obj["data"]["customer"]);
      String token = obj["data"]["payload"]["token"];
      customer.token = token;
    } catch (_) {
    }
    return customer;
  }


  static Future<CustomerModel> updateCustomerPersist (CustomerModel customer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String jsonCustomer = prefs.getString("_loginResponse");
      var obj = json.decode(jsonCustomer);
      String token = obj["data"]["payload"]["token"];
//      customer = CustomerModel.fromJson(obj["data"]["customer"]);
      customer.token = token;
      obj['data']['customer'] = customer.toJson();
      String _sd = json.encode(obj);
      prefs.setString("_loginResponse", _sd);
    } catch (_) {
 print ("error updateCustomerPersist");
    }
    return customer;
  }


  static Future<void> clearCustomerInformations () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("_loginResponse");
    prefs.clear();
    /*String jsonCustomer = prefs.getString("_loginResponse");
    var obj = json.decode(jsonCustomer);
    CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
    String token = obj["data"]["payload"]["token"];
    customer.token = token;
    return customer;*/
  }

  static Future<UserTokenModel> getUserToken () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonCustomer = prefs.getString("_loginResponse");

    String tok="";

    try {
      var obj = json.decode(jsonCustomer);
      tok = obj["data"]["payload"]["token"];
    } catch (_) {
      print(_);
    }

    UserTokenModel token = UserTokenModel(token: tok);
    return token;
  }

  static getOldWelcomePage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonHomePage = prefs.getString("_homepage");
    return jsonHomePage;
  }

  static saveWelcomePage(String wp) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_homepage", wp);
  }



}