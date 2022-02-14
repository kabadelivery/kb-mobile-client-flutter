import 'dart:convert';

import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomerUtils {


  static persistTokenAndUserdata(String token, String loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("_loginResponse", loginResponse);
    /* no need to commit */
    /* expiration date in 3months */
    String expDate = "${DateTime.now().add(Duration(days: 180)).millisecondsSinceEpoch}";
    prefs.setString("${ServerConfig.LOGIN_EXPIRATION}", expDate);
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
      customer.created_at = obj["data"]["customer"]["created_at"];
      // created_at
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
      xrint ("error updateCustomerPersist");
    }
    return customer;
  }


  static Future<void> clearCustomerInformations () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("_loginResponse");
    prefs.remove("${ServerConfig.LOGIN_EXPIRATION}");
    prefs.remove("_homepage");
    prefs.remove("is_push_token_uploaed");

// prefs.clear();
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
      xrint(_);
    }

    UserTokenModel token = UserTokenModel(token: tok);
    return token;
  }

  static Future<String> getLoginOtpCode () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String otp = ".";
    try {
      String jsonCustomer = prefs.getString("_loginResponse");
      var obj = json.decode(jsonCustomer);
      otp = obj["login_code"];
      xrint("getLoginOtpCode :: otp = ${otp}");
    } catch (_) {
      xrint("getLoginOtpCode :: otp retrieve error");
    }
    return otp;
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

  static Future<void> saveOtpToSharedPreference(String username, String otp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("${username}_last_otp", otp);
    prefs.setString("${username}_otp_saved_time", "${DateTime.now().millisecondsSinceEpoch~/1000}");
  }

  static Future<void> clearOtpLoginInfoFromSharedPreference(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      prefs.remove("${username}_otp_saved_time");
      prefs.remove("${username}_last_otp");
    } catch(_){
      xrint(_);
    }
  }


  static Future<String> getLastValidOtp({String username, MIN_LAPSED_SECONDS = 60*5}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String otp_saved_time = prefs.getString("${username}_otp_saved_time");
      if (int.parse(otp_saved_time) + MIN_LAPSED_SECONDS > (DateTime
          .now()
          .millisecondsSinceEpoch / 1000)) {
        return prefs.getString("${username}_last_otp");
      } else {
        return "no";
      }
    } catch(_) {
      return "no";
    }
  }

  static Future<String> getLastOtp(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("${username}_last_otp")) {
      return prefs.getString("${username}_last_otp");
    } else {
      return "no";
    }
  }

  static Future<bool> isPusTokenUploaded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_push_token_uploaded") == true;
  }

  static Future<void> setPushTokenUploadedSuccessfully() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_push_token_uploaded", true);
  }

  static bool isGpsLocation(String gps_latlong) {
    /* if gps location is under the format z.xxxxxx,y.xxxxx,
    * thus two different numbers with a length or minimum 6 chars each,
    * we confirm it's a gps location */
    List<String> latlong = gps_latlong.split(",").toList();
    if (latlong.length == 2 &&
        double.parse(latlong[0]).isFinite && double.parse(latlong[0]).abs() <= 90
        && double.parse(latlong[1]).isFinite && double.parse(latlong[1]).abs() <= 180){
      return true;
    }
    return false;
  }



}