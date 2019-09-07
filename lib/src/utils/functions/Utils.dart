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

//    headers["Authorization"] = "Bearer "+token;

    return headers;
  }

  static Map<String, String> getHeadersWithToken (String token) {

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

  static String token = "eyJhbGciOiJSUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwidXNlcm5hbWUiOiI5MDYyODcyNSIsImlhdCI6MTU2MzQ4MjExNSwiZXhwIjoxNTk0NTg2MTE1fQ.DP2qV_BpF8NzT7cMA6_6nDIIep7A_vL7UqVhOK4-JVOFhkOrpm6aj8MRLP0D6V40GbfT-np12tNh-UKJlokE7txtM-Y1vSRh41JV3FuFxKSblpmXhi-RYF7V-TcAJWJp3AslUJjB50NyjTe-GQ1mK758RpfX-fwUt6T0jvOJqU8nny8DmqWtpbwPH3PRii3lLlDreXz696raktXIFmobZ7pqH5gbTAQ_t5BCtYijhF8QvbIxIXyQ_RDNutzOuPEQLZLBXhqJmo5gB90EMYJzRzeZLlsJ6rlcQ_aCW0acxSC7hnXpRycQE1NFXSGF3i502KriFOC_lwN8oJxfdtyOSYvn6ZcA_JCVD58DoWk3qBwXBFJ2_z0luQzxrY0IeB8fROJTd5jaLR01JO7KtA4f1-AdaR8t7vL1yA6v-T7LtWFyIapSdoiyTaaluGHHp7vB_Ccn-qwT5LoMZraQq2nBv33SB6KNZGwQHnTrYhIypNMhBuHcEiXUBTZXtEKDgU3FQy2f6RsZmw5jtF49i7YVNLZkh4_-tKNy5ZPcjhhwZL2-MC7-klHJI6KBkcf01tWZa45wzMY14U5OTc6ZaHnB10KwmgD0dZcjhW--_6mKLC2pBQY-t-lm8PuOyXZzFjh68vsN9I3e2jJDhkRrgAbFU12gsTUrqu1SPsk9xSa3L0g";

static String timestampToDate (String timestamp) {

   return "";
}
}

/*
* final SharedPreferences prefs = await SharedPreferences.getInstance();
    String numbersJson = prefs.getString(_kFavoritePhoneNumbersPrefs)

     final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_kFavoritePhoneNumbersPrefs, json.encode(numbersList));


*
* */