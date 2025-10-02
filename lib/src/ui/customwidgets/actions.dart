import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../contracts/transaction_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../screens/home/me/money/TransactionHistoryPage.dart';

Widget ActionsWidget({required BuildContext context,IconData ? icon,String? label,required Color color,void Function()? onTap}) {
  return  InkWell(
    onTap: () =>onTap,
    child: Container(
        width: 80,
      height: 65,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: color.withOpacity(.3),
          borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //                                    IconButton (icon:Icon(Icons.monetization_on, color: KColors.primaryColor, size: 40)),
          Icon(icon,
              color:color, size: 30),
          Center(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label??"",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:color,
                        fontSize: 12),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}

