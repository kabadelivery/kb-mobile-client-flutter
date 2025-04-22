import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShippingFeeTag extends StatefulWidget {
  String distance;

  ShippingFeeTag(this.distance);

  @override
  _ShippingFeeTagState createState() {
    return _ShippingFeeTagState();
  }
}

class _ShippingFeeTagState extends State<ShippingFeeTag> {
  @override
  void initState() {
    super.initState();
    //  if customer is not logged and there is no selected address, there is nothing to show
  }

  void inflateBillingInformation() {
    xrint(StateContainer.of(context).myBillingArray.toString());
    if (StateContainer.of(context).myBillingArray == null) {
      CustomerUtils.getLastStoredBilling().then((value) {
        try {
          dynamic data = mJsonDecode(value); // get from json
          // fetch billing from the one stored locally
          bool is_email_account = StateContainer.of(context).customer == null ||
                  StateContainer.of(context).customer?.username == null
              ? false
              : (StateContainer.of(context).customer!.username!.contains("@")
                  ? true
                  : false);

          Map<String, String> myBillingArray = Map();

          List<dynamic> lBilling =
              data[is_email_account ? "email" : "phoneNumber"];
          for (int s = 0; s < lBilling.length; s++) {
            int from = int.parse(lBilling[s]["from"]);
            int to = int.parse(lBilling[s]["to"]);
            int value = int.parse(lBilling[s]["value"]);

            // we take upper border
            myBillingArray["${from}"] = "${value}";
            if (to - from > 1) {
              for (int i = from + 1; i < to; i++) {
                myBillingArray["${i}"] = "${value}";
              }
            }
          }

          /* update platform billing into state container */
          StateContainer.of(context).myBillingArray = myBillingArray;

        } catch (e) {
          xrint(e);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inflateBillingInformation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (StateContainer.of(context).location == null) return Container();

    var shipping_price = _getShippingPrice(
        widget.distance, StateContainer.of(context).myBillingArray!);

    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: KColors.new_gray),
        child: Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.biking,
                color: KColors.primaryColor, size: 12),
            SizedBox(width: 5),
            Text(
                (shipping_price == "~"
                    ? "${AppLocalizations.of(context)!.translate('out_of_range')}"
                    : shipping_price + " F"),
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ));
  }

  String _getShippingPrice(
      String distance, Map<String, String> myBillingArray) {
    try {
      int distanceInt = int.parse(
          !distance.contains(".") ? distance : distance.split(".")[0]);
      if (myBillingArray["$distanceInt"] == null) {
        return "~";
      } else {
        return myBillingArray["$distanceInt"]!;
      }
    } catch (_) {
      xrint(_);
      return "~";
    }
  }
}
