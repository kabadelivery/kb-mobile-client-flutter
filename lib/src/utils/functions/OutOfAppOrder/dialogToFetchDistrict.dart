import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/district_state.dart';
import '../../../ui/customwidgets/MyLoadingProgressWidget.dart';

Future<List<Map<String, dynamic>>> fetchDistricts() async {
  CustomerModel? customer = await CustomerUtils.getCustomer();

  OutOfAppOrderApiProvider apiProvider = OutOfAppOrderApiProvider();
  List<Map<String, dynamic>> response =
      await apiProvider.fetchDistricts(customer!);
  response.sort((a, b) => a["name"].compareTo(b["name"]));

  // Save new data to cache
  await CustomerUtils.setCachedDistricts(response);

  return response;
}

Future<List<Map<String, dynamic>>> showLoadingDialog(
    BuildContext context) async {
  return showDialog<List<Map<String, dynamic>>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDistricts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              content: MyLoadingProgressWidget(),
              backgroundColor: Colors.transparent,
              elevation: 0,
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop(snapshot.data);
            return SizedBox();
          }
        },
      );
    },
  ).then((value) => value ?? []);
}
