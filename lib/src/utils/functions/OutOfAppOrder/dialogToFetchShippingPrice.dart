import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localizations/AppLocalizations.dart';
import 'launchOrder.dart';
import 'out_of_app_sharedPref.dart';

Future<bool?> showShippingPriceRangeInfo(BuildContext context, WidgetRef ref, int type_of_order) async {
  Map<String, dynamic> prices = await OutOfAppSharedPrefs.getStringMap();
  String minPrice = prices["minimum"] ?? "?";
  String maxPrice = prices["maximum"] ?? "?";

   bool? result = await  showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Fluctuation du prix",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "${AppLocalizations.of(context)!.translate('the_shipping_price_can_change')} $minPrice CFA ${AppLocalizations.of(context)!.translate('and')} $maxPrice CFA ${AppLocalizations.of(context)!.translate('depending_on_store_location')}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context,false);
            },
            child: Text(AppLocalizations.of(context)!.translate("cancel")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context,true);
            },
            child: Text(AppLocalizations.of(context)!.translate("next")),
          ),
        ],
      );
    },
  );
  return result;
}
