import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

Future<Map<String, dynamic>> subscribeByCode({required String code}) async {
  final dio = Dio();
  CustomerModel customer = await CustomerUtils.getCustomer();
  try {
    final response = await dio.post(
      ServerRoutes.LINK_SUBSCRIBE_BY_CODE,
      data: {"Code": code,'user_id':customer.id.toString()},
      options: Options(
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer tonToken",
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
     return {
        "success": true,
     };
    } else {
      debugPrint("Erreur serveur: ${response.statusCode}");
      return {
        "success": false,
        "message": "Erreur serveur: ${response.statusCode}",
      };
    }
  } on DioError catch (e) {
    debugPrint("Erreur serveur: ${e}");
    return {
      "success": false,
      "message": e.response?.data ?? e.message,
    };
  } catch (e) {
    debugPrint("Erreur serveur: ${e}");
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}
