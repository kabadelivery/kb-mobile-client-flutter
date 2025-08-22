import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/DeliveryRatingPending.dart';

void saveRatePendingInCache(String deliveryRatingPending)async{
  SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
  await prefs.setString("DeliveryRatingPending", deliveryRatingPending);
}

Future<DeliveryRatingPending?> getRatePendingFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deliveryRatingPending = prefs.getString("DeliveryRatingPending");
  if (deliveryRatingPending != null) {
    return DeliveryRatingPending.fromJson(jsonDecode(deliveryRatingPending));
  } else {
    print("No Delivery Rating Pending found in cache.");
    return null;
  }
}
void deleteRatePendingFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool removed = await prefs.remove("DeliveryRatingPending");
  if (removed) {
    print("Delivery Rating Pending removed from cache.");
  } else {
    print("No Delivery Rating Pending found to remove.");
  }
}