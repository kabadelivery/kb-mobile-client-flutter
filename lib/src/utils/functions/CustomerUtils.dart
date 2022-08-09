import 'dart:convert';

import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerUtils {
  static String signature = XRINT_DEBUG_VALUE ? "debug" : "prod";

  static persistTokenAndUserdata(String token, String loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("_loginResponse" + signature, loginResponse);
    /* no need to commit */
    /* expiration date in 3months */
    String expDate =
        "${DateTime.now().add(Duration(days: 180)).millisecondsSinceEpoch}";
    prefs.setString("${ServerConfig.LOGIN_EXPIRATION}", expDate);
  }

  static Future<CustomerModel> getCustomer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CustomerModel customer;
    try {
      String jsonCustomer = prefs.getString("_loginResponse" + signature);
      var obj = json.decode(jsonCustomer);
      customer = CustomerModel.fromJson(obj["data"]["customer"]);
      String token = obj["data"]["payload"]["token"];
      customer.token = token;
      customer.created_at = obj["data"]["customer"]["created_at"];
      // created_at
    } catch (_) {
      customer = null;
    }
    return customer;
  }

  static Future<CustomerModel> updateCustomerPersist(
      CustomerModel customer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String jsonCustomer = prefs.getString("_loginResponse" + signature);
      var obj = json.decode(jsonCustomer);
      String token = obj["data"]["payload"]["token"];
//      customer = CustomerModel.fromJson(obj["data"]["customer"]);
      customer.token = token;
      obj['data']['customer'] = customer.toJson();
      String _sd = json.encode(obj);
      prefs.setString("_loginResponse" + signature, _sd);
    } catch (_) {
      xrint("error updateCustomerPersist");
    }
    return customer;
  }

  static Future<void> clearCustomerInformations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("_loginResponse" + signature);
    prefs.remove("${ServerConfig.LOGIN_EXPIRATION}");
    prefs.remove("_homepage" + signature);
    prefs.remove("is_push_token_uploaed");
    prefs.remove("_selectedAddress" + signature);

// prefs.clear();
    /*String jsonCustomer = prefs.getString("_loginResponse"+signature);
    var obj = json.decode(jsonCustomer);
    CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
    String token = obj["data"]["payload"]["token"];
    customer.token = token;
    return customer;*/
  }

  static Future<UserTokenModel> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonCustomer = prefs.getString("_loginResponse" + signature);

    String tok = "";

    try {
      var obj = json.decode(jsonCustomer);
      tok = obj["data"]["payload"]["token"];
    } catch (_) {
      xrint(_);
    }

    UserTokenModel token = UserTokenModel(token: tok);
    return token;
  }

  static Future<String> getLoginOtpCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String otp = ".";
    try {
      String jsonCustomer = prefs.getString("_loginResponse" + signature);
      var obj = json.decode(jsonCustomer);
      otp = obj["login_code"];
      xrint("getLoginOtpCode :: otp = ${otp}");
    } catch (_) {
      xrint("getLoginOtpCode :: otp retrieve error");
    }
    return otp;
  }

  static saveCategoryConfiguration(String ct) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_category" + signature, ct);
  }

  static getOldCategoryConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String categoryConfig = prefs.getString("_category" + signature);
    return categoryConfig;
  }

  static saveWelcomePage(String wp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_homepage" + signature, wp);
  }

  static getOldWelcomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonContent = prefs.getString("_homepage" + signature);
    return jsonContent;
  }

  static saveBestSellerPage(String wp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_b_seller" + signature, wp);
  }

  static getOldBestSellerPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonContent = prefs.getString("_b_seller" + signature);
    return jsonContent;
  }

  static Future<void> saveFavoriteAddress(List<int> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_favorite_list" + signature, json.encode(favorites));
  }

  static Future<List<int>> getFavoriteAddress() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String favorite_list = prefs.get("_favorite_list" + signature);
      return json.decode(favorite_list);
    } catch(e){
      return [];
    }
  }

  static Future<void> saveAddressLocally(
      DeliveryAddressModel selectedAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "_selectedAddress" + signature, json.encode(selectedAddress.toJson()));
  }

  static Future<DeliveryAddressModel> getSavedAddressLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.get("_selectedAddress" + signature);
    return DeliveryAddressModel.fromJson(json.decode(address));
  }

  static Future<void> saveOtpToSharedPreference(
      String username, String otp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("${username}_last_otp" + signature, otp);
    prefs.setString("${username}_otp_saved_time" + signature,
        "${DateTime.now().millisecondsSinceEpoch ~/ 1000}");
  }

  static Future<void> clearOtpLoginInfoFromSharedPreference(
      String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.remove("${username}_otp_saved_time" + signature);
      prefs.remove("${username}_last_otp" + signature);
    } catch (_) {
      xrint(_);
    }
  }

  static Future<String> getLastValidOtp(
      {String username, MIN_LAPSED_SECONDS = 60 * 5}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String otp_saved_time =
          prefs.getString("${username}_otp_saved_time" + signature);
      if (int.parse(otp_saved_time) + MIN_LAPSED_SECONDS >
          (DateTime.now().millisecondsSinceEpoch / 1000)) {
        return prefs.getString("${username}_last_otp" + signature);
      } else {
        return "no";
      }
    } catch (_) {
      return "no";
    }
  }

  static Future<String> getLastOtp(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("${username}_last_otp" + signature)) {
      return prefs.getString("${username}_last_otp" + signature);
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
        double.parse(latlong[0]).isFinite &&
        double.parse(latlong[0]).abs() <= 90 &&
        double.parse(latlong[1]).isFinite &&
        double.parse(latlong[1]).abs() <= 180) {
      return true;
    }
    return false;
  }
}
