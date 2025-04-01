import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OutOfAppSharedPrefs {
  static const String shipping_price_range = "shipping_price_range";

  static Future<void> saveStringMap(Map<String, dynamic> map) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMap = jsonEncode(map);
    await prefs.setString(shipping_price_range, encodedMap);
  }

  static Future<Map<String, dynamic>> getStringMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMap = prefs.getString(shipping_price_range);
    if (encodedMap == null) return {};
    Map<String, dynamic> decodedMap = jsonDecode(encodedMap);
    if (decodedMap == null) return {};
    return decodedMap.map((key, value) => MapEntry(key, value.toString()));
  }
}
