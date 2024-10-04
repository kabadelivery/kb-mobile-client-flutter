import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

int hexToInt(String code) {
  return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
}

int mHexToInt(String code) {
  return int.parse(code);
}

mJsonDecode(var source) {
  if (source is String) {
    return json.decode(source);
  } else {
    return source;
  }
}

class Utils {
  static Map<String, String> getHeaders() {
    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["cache-control"] = "no-cache";
    return headers;
  }

  static Map<String, String> getHeadersWithToken(String token) {
    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["cache-control"] = "no-cache";
    if (token != null) headers["Authorization"] = "Bearer " + token;
    return headers;
  }

  static Map<String, String> getDioHeadersWithToken(String token) {
    return {
      "Authorization": "Bearer " + token,
      "cache-control": "no-cache",
      Headers.contentTypeHeader: Headers.jsonContentType,
    };
  }

  static inflateLink(String link) {
    if (link != null) {
      String slash = (link.length > 0 && link.indexOf("/") == 0) ? "" : "/";
      return ServerConfig.IMAGE_BUCKET_BASE_LINK + slash + link;
    } else
      return ServerConfig.IMAGE_BUCKET_BASE_LINK +
          "/default_pic/kaba_red_rectangle.png";
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

  static String token =
      "eyJhbGciOiJSUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwidXNlcm5hbWUiOiI5MDYyODcyNSIsImlhdCI6MTU2MzQ4MjExNSwiZXhwIjoxNTk0NTg2MTE1fQ.DP2qV_BpF8NzT7cMA6_6nDIIep7A_vL7UqVhOK4-JVOFhkOrpm6aj8MRLP0D6V40GbfT-np12tNh-UKJlokE7txtM-Y1vSRh41JV3FuFxKSblpmXhi-RYF7V-TcAJWJp3AslUJjB50NyjTe-GQ1mK758RpfX-fwUt6T0jvOJqU8nny8DmqWtpbwPH3PRii3lLlDreXz696raktXIFmobZ7pqH5gbTAQ_t5BCtYijhF8QvbIxIXyQ_RDNutzOuPEQLZLBXhqJmo5gB90EMYJzRzeZLlsJ6rlcQ_aCW0acxSC7hnXpRycQE1NFXSGF3i502KriFOC_lwN8oJxfdtyOSYvn6ZcA_JCVD58DoWk3qBwXBFJ2_z0luQzxrY0IeB8fROJTd5jaLR01JO7KtA4f1-AdaR8t7vL1yA6v-T7LtWFyIapSdoiyTaaluGHHp7vB_Ccn-qwT5LoMZraQq2nBv33SB6KNZGwQHnTrYhIypNMhBuHcEiXUBTZXtEKDgU3FQy2f6RsZmw5jtF49i7YVNLZkh4_-tKNy5ZPcjhhwZL2-MC7-klHJI6KBkcf01tWZa45wzMY14U5OTc6ZaHnB10KwmgD0dZcjhW--_6mKLC2pBQY-t-lm8PuOyXZzFjh68vsN9I3e2jJDhkRrgAbFU12gsTUrqu1SPsk9xSa3L0g";

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

  static String timeStampToDate(String timestamp) {
    if (timestamp == null) return "";

    DateTime commandTime =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);

    String patternNotToday = "yyyy-MM-dd";
    DateFormat simpleDateFormat = DateFormat(patternNotToday);
    return simpleDateFormat.format(commandTime);
  }

  static getExpiryDay(String timestamp) {
    if (timestamp == null) return "";

    DateTime commandTime =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);

    String patternNotToday = "dd";
    DateFormat simpleDateFormat = DateFormat(patternNotToday);
    return simpleDateFormat.format(commandTime);
  }

  static String readTimestamp(BuildContext context, int timestamp) {
    DateTime commandTime =
        new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    DateTime currentTime = new DateTime.now();

    String pattern_not_today = "yyyy-MM-dd HH:mm:ss";
    String pattern_today = "HH:mm:ss";

    DateFormat simpleDateFormat = DateFormat();
    String formattedDate = "";

    if (commandTime.month == currentTime.month &&
        commandTime.year == currentTime.year) {
      simpleDateFormat = new DateFormat(pattern_today);
      formattedDate = simpleDateFormat.format(commandTime);
      if (commandTime.day == currentTime.day) {
        formattedDate = "${AppLocalizations.of(context).translate('today')}" +
            " " +
            formattedDate;
      } else if (commandTime.day + 1 == currentTime.day) {
        formattedDate =
            "${AppLocalizations.of(context).translate('yesterday')}" +
                " " +
                formattedDate;
      } else {
        simpleDateFormat = DateFormat(pattern_not_today);
        formattedDate = simpleDateFormat.format(commandTime);
      }
    } else {
      simpleDateFormat = DateFormat(pattern_not_today);
      formattedDate = simpleDateFormat.format(commandTime);
    }
    return formattedDate;
  }

  static bool isPhoneNumber_TGO(String phone_no) {
    if (phone_no == null || phone_no.length == 0) return false;
    final regex = RegExp(r'^[9,7]{1}[0,1,2,3,6,7,8,9]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isPhoneNumber_Tgcel(String phone_no) {
    if (phone_no == null || phone_no.length == 0) return false;
    final regex = RegExp(r'^[9,7]{1}[0-3]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isPhoneNumber_Moov(String phone_no) {
    if (phone_no == null || phone_no.length == 0) return false;
    final regex = RegExp(r'^[9,7]{1}[6-9]{1}[0-9]{6}$');
    bool res = regex.hasMatch(phone_no);
    return res;
  }

  static bool isCode /* 4 digits string */ (String code) {
    if (code == null || code.length != 4) return false;
    final regex = RegExp(r'^[0-9]{4}$');
    bool res = regex.hasMatch(code);
    return res;
  }

  static String inflatePrice(String balance) {
    if (balance == null || "" == (balance)) balance = "0";

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
    } catch (_) {
      return "...";
    }
  }

  static bool isEmailValid(String email) {
    if (email == null || email.length == 0) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    bool res = regex.hasMatch(email);
    return res;
  }

  static String reverseString(String balance) {
    return balance.split('').reversed.join('');
  }

  static String hidePhoneNumber(String phoneNumberEmail) {
    if (phoneNumberEmail == null) return "********";
    if (Utils.isEmailValid(phoneNumberEmail)) {
      // hide email
      int ind = phoneNumberEmail.lastIndexOf("@");
      if (ind > 3) {
        return phoneNumberEmail.substring(0, 3) +
            "****" +
            phoneNumberEmail.substring(ind);
      } else {
        phoneNumberEmail;
      }
    } else if (Utils.isPhoneNumber_TGO(phoneNumberEmail)) {
      // hide phone number
      return phoneNumberEmail.substring(0, 2) +
          "****" +
          phoneNumberEmail.substring(6, 8);
    } else {
      return "********";
    }
  }

  static String timeStampToDayDate(String timeStamp, {List<String> dayz}) {
    try {
      int unixSeconds = int.parse(timeStamp);
      DateTime date =
          new DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

      int day_of_week = date.weekday;

      if (dayz == null || dayz.length != 7)
        dayz = [
          "Lundi",
          "Mardi",
          "Mercredi",
          "Jeudi",
          "Vendredi",
          "Samedi",
          "Dimanche"
        ];

      int day = date.day;
      int month = date.month;

      String daY = dayz[day_of_week - 1];
      daY += ("(" +
          (day > 0 && day <= 9 ? "0" : "") +
          "${day}/" +
          (month > 0 && month <= 9 ? "0" : "") +
          "${month})");
      return daY;
    } catch (e) {
      e.xrintStackTrace();
    }
    return "-- --";
  }

  static String timeStampToHourMinute(String timeStamp) {
    try {
      int unixSeconds = int.parse(timeStamp);
      DateTime date =
          new DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
      return new DateFormat("Hm").format(date);
    } catch (e) {
      e.xrintStackTrace();
    }
    return "-- --";
  }

  static bool within3days(String last_update) {
    int orderLastUpdate = int.parse(last_update);
    return orderLastUpdate >
        (DateTime.now().millisecondsSinceEpoch / 1000 - 3 * 3600 * 24);
  }

  // function to generate a random string of length n
  static String getAlphaNumericString({int n = 9}) {
    String str = "RandomString_";
    int nb = new Random().nextInt(1000);
    for (int i = 0; i < n; i++) {
      str += "${nb}";
    }
    // return the resultant string
    return str;
  }

  static bool isEndDateReached(String endTimeStamp) {
    DateTime endDate =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(endTimeStamp) * 1000);
    return endDate.isBefore(DateTime.now());
  }

  static bool isWebLink(String link) {
    bool _validURL = Uri.parse(link).isAbsolute;
    return _validURL;
  }

  static double locationDistance(Position position, ShopModel restaurant) {
    try {
      double lat1 = position.latitude;
      double long1 = position.longitude;
      double lat2 = double.parse(restaurant.location.split(":")[0]);
      double long2 = double.parse(restaurant.location.split(":")[1]);
      double distance =
          Geolocator.distanceBetween(lat1, long1, lat2, long2); // meter
      distance = 1.15 /* error factor */ * distance / 1000; // distance meter
      return double.parse(distance.toStringAsPrecision(1));
      // crop to 1 number after comma
    } catch (e) {
      xrint(e);
      return 100;
    }
  }

  static String capitalize(String s) {
    if (s.length < 2) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }

  static String replaceNewLineBy(String text, String placebo) {
    return text.replaceAll("\n", placebo);
  }
}
