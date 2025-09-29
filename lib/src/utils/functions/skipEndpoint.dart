import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

Future<bool> CanSkipEndpoint()async {
  CustomerModel customer = await CustomerUtils.getCustomer();
  Dio dio = Dio();
  try {
    final response = await dio.get(ServerRoutes.LINK_GET_SKIP_NOTATION_STATUS,
    options: Options(
      headers: {
        'Authorization': 'Bearer ${customer.token}',
        'Content-Type': 'application/json',
      },
    )
    );
    if (response.statusCode == 200) {
      bool canSkip = response.data['enabled'];
      return canSkip;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint('Error occurred: $e');
    return false;
  }
}