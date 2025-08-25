import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/DeliveryRatingPending.dart';

void saveRatePendingInCache(String deliveryRatingPending)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("DeliveryRatingPending", deliveryRatingPending);
  print("Delivery Rating Pending saved to cache. ${deliveryRatingPending}");
}

Future<List<DeliveryRatingPending>?> getRatePendingFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deliveryRatingPending = prefs.getString("DeliveryRatingPending");
  List<DeliveryRatingPending> deliveriesRatingPending = [];
  var  deliveryRatingPendingList = jsonDecode(deliveryRatingPending ?? '[]');
  debugPrint("Delivery Rating Pending from cache: ${deliveryRatingPendingList}");
  for (var deliveryRatingPending in deliveryRatingPendingList) {
    deliveriesRatingPending.add(DeliveryRatingPending.fromJson(deliveryRatingPending));
  }
  if (deliveryRatingPending != null) {
    return deliveriesRatingPending;
  } else {
    print("No Delivery Rating Pending found in cache.");
    return null;
  }
}
void removeSingleRatePendingFromCache(String commandId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<DeliveryRatingPending>? deliveriesRatingPending = await getRatePendingFromCache();
  if (deliveriesRatingPending != null) {
    deliveriesRatingPending.removeWhere((element) => element.command_id == commandId);
    if(deliveriesRatingPending.isEmpty){
      await prefs.remove("DeliveryRatingPending");
      print("All Delivery Rating Pending removed from cache.");
      return;
    }
    await prefs.setString("DeliveryRatingPending", json.encode(deliveriesRatingPending.map((e) => e.toJson()).toList()));
    print("Delivery Rating Pending with command_id $commandId removed from cache.");
  } else {
    print("No Delivery Rating Pending found to remove.");
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