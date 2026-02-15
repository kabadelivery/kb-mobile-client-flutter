import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:http/http.dart' as http;

import '../_static_data/ServerRoutes.dart';

Future<bool> fetchSubscription() async {
  CustomerModel customerModel = await CustomerUtils.getCustomer();
  final url = Uri.parse(
    "${ServerRoutes.KABA_ABONNEMENT_SUSCRIBED_USER}/${customerModel.id}",
  );
  try {
    final response = await http
        .get(url)
        .timeout(const Duration(milliseconds: 5000));
    if (response.statusCode == 200) {
      final rawData = json.decode(response.body);
      if (rawData is! Map<String, dynamic>) {
        throw Exception("Unexpected response format: not a JSON object");
      }
      Map<String, dynamic> normalizedData = Map<String, dynamic>.from(rawData);
     if( normalizedData["subscription_id"]!=null){
       return true;
     }else return false;
  }
  }catch (e) {
    return false;
  }
  return false;
}

