import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerUtils {
  static String signature = kDebugMode ? "debug" : "prod";

  static persistTokenAndUserdata(String token, String loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("_loginResponse" + signature, loginResponse);
    String expDate =
        "${DateTime.now().add(Duration(days: 180)).millisecondsSinceEpoch}";
    prefs.setString(
        "${ServerConfig.LOGIN_EXPIRATION}" + CustomerUtils.signature, expDate);
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
    prefs.remove("${ServerConfig.LOGIN_EXPIRATION}" + signature);
    prefs.remove("_homepage_" + signature);
    prefs.remove("is_push_token_uploaded");
    prefs.remove("_selectedAddress" + signature);
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
      xrint("getLoginOtpCode :: otp = $otp");
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
    prefs.setString("_homepage_" + signature, wp);
  }

  static getOldWelcomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonContent = prefs.getString("_homepage_" + signature);
    return jsonContent;
  }

  static saveBestSellerVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("_best_seller_version" + signature,
        DateTime.now().millisecondsSinceEpoch);
  }

  static getBestSellerLockDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      int mls = prefs.getInt("_best_seller_version" + signature);
      if (mls == null) mls = 0;
      return mls;
    } catch (e) {
      return 0;
    }
  }

  static getProposalLockDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      int mls = prefs.getInt("_proposal_version" + signature);
      if (mls == null) mls = 0;
      return mls;
    } catch (e) {
      return 0;
    }
  }

  static saveProposalVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        "_proposal_version" + signature, DateTime.now().millisecondsSinceEpoch);
  }

  static canLoadProposal() async {
    int tmp = 0;
    try {
      tmp = await getProposalLockDate();
      if (DateTime.now().millisecondsSinceEpoch - tmp >
          1000 * 60 * 60 * 6) // 6 hours maximums after, need to reload proposal
        return true;
      return false;
    } catch (e) {
      xrint(e);
      return true;
    }
  }

  static canLoadBestSeller() async {
    int tmp = 0;
    try {
      tmp = await getBestSellerLockDate();
      if (DateTime.now().millisecondsSinceEpoch - tmp >
          1000 *
              60 *
              60 *
              24 *
              3) // 3 days maximums after, need to reload best seller
        return true;
      return false;
    } catch (e) {
      xrint(e);
      return true;
    }
  }

  static unlockBestSellerVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("_best_seller_version" + signature);
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

  static getOldProposalPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonContent = prefs.getString("_proposal_" + signature);
    return jsonContent;
  }

  static saveProposalPage(String proposalsJson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_proposal_" + signature, proposalsJson);
  }

  static saveShopSchedulePage(int restaurantId, String wp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_restaurant_schedule_${restaurantId}_" + signature, wp);
  }

  static getOldShopSchedulePage(int restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonContent =
        prefs.getString("_restaurant_schedule_${restaurantId}_" + signature);
    return jsonContent;
  }

  static Future<void> saveFavoriteAddress(List<int> favorites) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_favorite_list" + signature, json.encode(favorites));
  }

  static Future<List<int>> getFavoriteAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String favoriteList = prefs.get("_favorite_list" + signature);
      List<dynamic> res = json.decode(favoriteList);
      List<int> ress = [];
      res.forEach((element) {
        ress.add(element);
      });
      return ress;
    } catch (e) {
      return Future.value(List<int>.empty(growable: true));
    }
  }

  static Future<void> saveAddressLocally(Position selectedAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "_selectedAddress" + signature, json.encode(selectedAddress.toJson()));
  }

  static Future<Position> getSavedAddressLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String address = prefs.get("_selectedAddress" + signature);
      var res = Position.fromMap(json.decode(address));
      return res;
    } catch (e) {
      return null;
    }
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
      {String username, minLapsedSeconds = 60 * 5}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String otpSavedTime =
          prefs.getString("${username}_otp_saved_time" + signature);
      if (int.parse(otpSavedTime) + minLapsedSeconds >
          (DateTime.now().millisecondsSinceEpoch / 1000)) {
        return prefs.getString("${username}_last_otp" + signature);
      } else {
        return "no";
      }
    } catch (_) {
      return "no";
    }
  }

  static Future<String> getLastStoredBilling() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("_billing" + signature);
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

  static bool isGpsLocation(String gpsLatLong) {
    /* if gps location is under the format z.xxxxxx,y.xxxxx,
    * thus two different numbers with a length or minimum 6 chars each,
    * we confirm it's a gps location */
    List<String> latlong = gpsLatLong.split(",").toList();
    if (latlong.length == 2 &&
        double.parse(latlong[0]).isFinite &&
        double.parse(latlong[0]).abs() <= 90 &&
        double.parse(latlong[1]).isFinite &&
        double.parse(latlong[1]).abs() <= 180) {
      return true;
    }
    return false;
  }

  static Future<void> updateBillingLocally(String billing) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_billing" + signature, billing);
  }

  /* save configuration  */
  static Future<void> updateShopListFilterConfiguration(
      Map<String, dynamic> configuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.setString(
          "_shop_list_filter" + signature, json.encode(configuration));
    } catch (e) {
      xrint(e);
    }
  }

/*  get configuration */
  static Future<Map<String, dynamic>> getShopListFilterConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String tmp = prefs.getString("_shop_list_filter" + signature);
      return json.decode(tmp);
    } catch (e) {
      return Map<String, dynamic>();
    }
  }

  static Future<void> setCachedDistricts(List<Map<String, dynamic>> districts) async {
    const String _cacheKey = 'cached_districts';
    const String _timestampKey = 'cache_timestamp';
    const int _cacheDurationDays = 10;
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(districts);
    await prefs.setString(_cacheKey, jsonData);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_timestampKey, timestamp);
  }
  static Future<List<Map<String, dynamic>>> getCachedDistricts() async {
    const String _cacheKey = 'cached_districts';
    const String _timestampKey = 'cache_timestamp';
    const int _cacheDurationDays = 10;
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString(_cacheKey);
    int timestamp = prefs.getInt(_timestampKey);

    if (jsonData == null || timestamp == null) return [];

    // Check if cache is expired
    DateTime cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime expiryTime = cacheTime.add(Duration(days: _cacheDurationDays));

    if (DateTime.now().isAfter(expiryTime)) {
      await clearDistrictCache();
      return [];
    }
    
    List<dynamic> decodedList = jsonDecode(jsonData);
    return List<Map<String, dynamic>>.from(decodedList);
  }
  static Future<void> clearDistrictCache() async {
    final prefs = await SharedPreferences.getInstance();
    const String _cacheKey = 'cached_districts';
    const String _timestampKey = 'cache_timestamp';
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
  Future<void> setViewUpdate({ bool enable}) async {
    const _keyViewUpdate = 'view_update';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyViewUpdate, enable);
  }
  Future<bool> getViewUpdate()async{
    const _keyViewUpdate = 'view_update';
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyViewUpdate) ?? false;

  }
}
