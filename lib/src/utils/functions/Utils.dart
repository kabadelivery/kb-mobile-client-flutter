import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerConfig.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

int hexToInt(String code) {
  return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
}


class Utils {
  static Map<String, String> getHeaders () {

    String token = "";
    Map<String, String> headers = Map();
    headers["Content-Type"] = "application/json";
    headers["cache-control"] = "no-cache";

    headers["Authorization"] = "Bearer "+token;

    return headers;
  }

  static inflateLink(String link) {
    return ServerConfig.SERVER_ADDRESS+"/"+link;
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



}

/*
* final SharedPreferences prefs = await SharedPreferences.getInstance();
    String numbersJson = prefs.getString(_kFavoritePhoneNumbersPrefs)

     final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_kFavoritePhoneNumbersPrefs, json.encode(numbersList));


*
* */