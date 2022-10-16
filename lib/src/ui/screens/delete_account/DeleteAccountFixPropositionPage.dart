import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeleteAccountSuccessfulPage extends StatefulWidget {
  static var routeName = "/DeleteAccountSuccessfulPage";

  @override
  State<StatefulWidget> createState() {
    return DeleteAccountSuccessfulPageState();
  }
}

class DeleteAccountSuccessfulPageState
    extends State<DeleteAccountSuccessfulPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('delete_account')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  color: Colors.blue,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "${AppLocalizations.of(context).translate("account_deleted")}",
                  style: TextStyle(
                      fontSize: 25,
                      color: KColors.new_black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("${AppLocalizations.of(context).translate("balance_dued")}".toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: KColors.primaryColor.withAlpha(30), borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text("10 000",
                        style: TextStyle(color: KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("${AppLocalizations.of(context).translate("currency")}",     style: TextStyle(color: KColors.primaryYellowColor, fontSize: 12, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "${AppLocalizations.of(context).translate("refund_within_72_hrs_description")}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          color: KColors.primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: Text(
                        "${AppLocalizations.of(context).translate("back_to_home")}".toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        ));
  }

  _deleteAccount() {}
}
