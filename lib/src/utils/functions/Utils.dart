import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:intl/intl.dart';


Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

int hexToInt(String code) {
  return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
}

int mHexToInt(String code) {
// return BigInt.parse(strip0x(code), radix: 16);
  return int.parse(code);
}

mJsonDecode(var source){
  if (source is String){
    return json.decode(source);
  } else {
    return source;
  }
}

class Utils {
  static Map<String, String> getHeaders() {
    String token = "";
    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["cache-control"] = "no-cache";
//    headers["Authorization"] = "Bearer "+token;
    return headers;
  }

  static Map<String, String> getHeadersWithToken(String token) {
    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["cache-control"] = "no-cache";
    headers["Authorization"] = "Bearer " + token;
    return headers;
  }

  static Map<String, String> getDioHeadersWithToken(String token) {
    return {
      "Authorization": "Bearer " + token,
      "cache-control" : "no-cache",
      Headers.contentTypeHeader: Headers.jsonContentType,
    };
  }

  static inflateLink(String link) {
    if (link != null) {
      String slash = (link.length > 0 && link.indexOf("/") == 0) ? "" : "/";
      return ServerConfig.UNSECURE_SERVER_ADDRESS + slash +link;
    } else
      return ServerConfig.UNSECURE_SERVER_ADDRESS+"/default_pic/kaba_red_rectangle.png";
  }

  static Future hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {}
    return false;
  }

  static String token = "eyJhbGciOiJSUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwidXNlcm5hbWUiOiI5MDYyODcyNSIsImlhdCI6MTU2MzQ4MjExNSwiZXhwIjoxNTk0NTg2MTE1fQ.DP2qV_BpF8NzT7cMA6_6nDIIep7A_vL7UqVhOK4-JVOFhkOrpm6aj8MRLP0D6V40GbfT-np12tNh-UKJlokE7txtM-Y1vSRh41JV3FuFxKSblpmXhi-RYF7V-TcAJWJp3AslUJjB50NyjTe-GQ1mK758RpfX-fwUt6T0jvOJqU8nny8DmqWtpbwPH3PRii3lLlDreXz696raktXIFmobZ7pqH5gbTAQ_t5BCtYijhF8QvbIxIXyQ_RDNutzOuPEQLZLBXhqJmo5gB90EMYJzRzeZLlsJ6rlcQ_aCW0acxSC7hnXpRycQE1NFXSGF3i502KriFOC_lwN8oJxfdtyOSYvn6ZcA_JCVD58DoWk3qBwXBFJ2_z0luQzxrY0IeB8fROJTd5jaLR01JO7KtA4f1-AdaR8t7vL1yA6v-T7LtWFyIapSdoiyTaaluGHHp7vB_Ccn-qwT5LoMZraQq2nBv33SB6KNZGwQHnTrYhIypNMhBuHcEiXUBTZXtEKDgU3FQy2f6RsZmw5jtF49i7YVNLZkh4_-tKNy5ZPcjhhwZL2-MC7-klHJI6KBkcf01tWZa45wzMY14U5OTc6ZaHnB10KwmgD0dZcjhW--_6mKLC2pBQY-t-lm8PuOyXZzFjh68vsN9I3e2jJDhkRrgAbFU12gsTUrqu1SPsk9xSa3L0g";


  static getStateColor(int state) {
    switch (state) {
      case 0:
        return CommandStateColor.waiting;
      case 1:
        return CommandStateColor.cooking;
      case 2:
        return CommandStateColor.shipping;
      case 3:
        return CommandStateColor.delivered;
      default:
        return CommandStateColor.cancelled;
    }
  }

  /* static String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }
*/



  static String timeStampToDate (String timestamp) {

    if (timestamp == null)
      return "";

    DateTime commandTime = new DateTime
        .fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);;
    String pattern_not_today = "yyyy-MM-dd";
    DateFormat sdf = DateFormat();
    String formattedDate = "";
    sdf = DateFormat(pattern_not_today);
    formattedDate = sdf.format(commandTime);
    return formattedDate;
  }

  static String readTimestamp (int timestamp) {

//      long unixSeconds = Long.parseLong(timeStamp);
    DateTime commandTime = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);;

    DateTime currentTime = new DateTime.now();

    String pattern_not_today = "yyyy-MM-dd HH:mm:ss";
    String pattern_today = "HH:mm:ss";

    DateFormat sdf = DateFormat();
//      sdf..setTimeZone(java.util.TimeZone.getTimeZone("GMT"));
    String formattedDate = "";

    if (commandTime.month == currentTime.month &&
        commandTime.year == currentTime.year) {
      sdf = new DateFormat(pattern_today);
      formattedDate = sdf.format(commandTime);
      if (commandTime.day == currentTime.day) {
        formattedDate = "TODAY" + " " + formattedDate;
      } else if (commandTime.day + 1 == currentTime.day) {
        formattedDate = "Yesterday" + " " + formattedDate;
      } else {
        sdf = DateFormat(pattern_not_today);
        formattedDate = sdf.format(commandTime);
      }
    } else {
      sdf = DateFormat(pattern_not_today);
      formattedDate = sdf.format(commandTime);
    }
    return formattedDate;
  }

  static bool isPhoneNumber_TGO (String phone_no) {
    if (phone_no == null || phone_no.length == 0)
      return false;
    final regex = RegExp(r'^[9,7]{1}[0,1,2,3,6,7,8,9]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isPhoneNumber_Tgcel (String phone_no) {
    if (phone_no == null || phone_no.length == 0)
      return false;
    final regex = RegExp(r'^[9,7]{1}[0-3]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isPhoneNumber_Moov (String phone_no) {
    if (phone_no == null || phone_no.length == 0)
      return false;
    final regex = RegExp(r'^[9,7]{1}[6-9]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isCode /* 4 digits string */ (String code) {
    if (code == null || code.length != 4)
      return false;
    final regex = RegExp(r'^[0-9]{4}$');
    bool res = regex.hasMatch(code);
    return res;
  }

  static String inflatePrice(String balance) {
    if (balance == null || "" == (balance))
      balance = "0";

    if (int.parse(balance) < 1000) {
      return balance;
    }

    String mbalance = reverseString(balance);
    try {
      xrint(mbalance);

      String res = "";

      for (int cx = 0; cx < mbalance.length; cx++) {
        res += (mbalance[cx]);
        if (cx % 3 == 2 && cx != 0 && cx + 1 != mbalance.length) {
          res += ".";
        }
      }
      xrint(reverseString(mbalance));
      return reverseString(res);
    } catch(_){
      return "...";
    }
  }

  static bool isEmailValid (String email) {
    if (email == null || email.length == 0)
      return false;
    final regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    bool res = regex.hasMatch(email);
    return res;
  }

  static String reverseString(String balance) {
    return balance.split('').reversed.join('');
  }

  static String hidePhoneNumber(String phone_number_email) {
    if (phone_number_email == null)
      return "********";
    if (Utils.isEmailValid(phone_number_email)) {
      // hide email
      int ind = phone_number_email.lastIndexOf("@");
      if (ind > 3) {
        return phone_number_email.substring(0,3)+"****"+phone_number_email.substring(ind);
      } else {
        phone_number_email;
      }
    } else  if (Utils.isPhoneNumber_TGO(phone_number_email)) {
      // hide phone number
      return phone_number_email.substring(0,2)+"****"+phone_number_email.substring(6,8);
    } else {
      return "********";
    }

  }

  static String timeStampToDayDate (String timeStamp, {List<String> dayz}) {

    try {
      int unixSeconds = int.parse(timeStamp);
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

      int day_of_week = date.weekday;

      if (dayz == null || dayz.length != 7)
        dayz = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];

      int day = date.day;
      int month = date.month;

      String daY = dayz[day_of_week-1];
      daY += ("("+(day>0 && day <=9 ? "0":"")+"${day}/"+(month>0 && month<=9? "0":"")+"${month})");
      return daY;

    } catch (e){
      e.xrintStackTrace();
    }
    return "-- --";
  }


  static String timeStampToHourMinute (String timeStamp) {

    try {
      int unixSeconds = int.parse(timeStamp);
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
      return new DateFormat("Hm").format(date);
    } catch (e){
      e.xrintStackTrace();
    }
    return "-- --";
  }

  static bool within3days(String last_update) {
    int orderLastUpdate = int.parse(last_update);
    return orderLastUpdate > (DateTime.now().millisecondsSinceEpoch/1000 - 3*3600*24);
  }


  // function to generate a random string of length n
  static String getAlphaNumericString({int n=9})
  {

    String str = "RandomString_";
    int nb = new Random().nextInt(1000);
    for (int i = 0; i < n; i++) {
      str+="${nb}";
    }
    // return the resultant string
    return str;
  }

  static bool isEndDateReached(String endTimeStamp) {

    DateTime endDate = new DateTime.fromMillisecondsSinceEpoch(int.parse(endTimeStamp) * 1000);
    return endDate.isBefore(DateTime.now());
  }

  static bool isWebLink(String link) {
    bool _validURL = Uri.parse(link).isAbsolute;
    return _validURL;
  }

  static double locationDistance(Position position, RestaurantModel restaurant) {

    double lat1 = position.latitude;
    double long1 = position.longitude;

    double lat2 = double.parse(restaurant.location.split(":")[0]);
    double long2 = double.parse(restaurant.location.split(":")[1]);

   double distance = Geolocator.distanceBetween(lat1, long1, lat2, long2); // meter
   distance = 1.3/* error factor */ * distance/1000; // distance meter
   return double.parse(distance.toStringAsPrecision(2));
    // crop to 1 number after comma
  }

}

