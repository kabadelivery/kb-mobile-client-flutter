import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeleteAccountRefundQuestionnaryPage extends StatefulWidget {
  static var routeName = "/DeleteAccountRefundQuestionnaryPage";

  @override
  State<StatefulWidget> createState() {
    return DeleteAccountRefundQuestionnaryPageState();
  }
}

class DeleteAccountRefundQuestionnaryPageState
    extends State<DeleteAccountRefundQuestionnaryPage> {
  bool _isAgreed = false;

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
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "${AppLocalizations.of(context).translate('please_fill_in_this_form')}",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "${AppLocalizations.of(context).translate('needed_to_send_remaining_balance')}",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      /* last name */
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(
                                    text:     "${AppLocalizations.of(context).translate('beneficiary_last_name')}",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.red))
                                ])),
                            Container(
                              decoration: BoxDecoration(
                                  color: KColors.new_gray,
                                  borderRadius: BorderRadius.circular(5)),
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                      child: TextField(
                                    decoration: InputDecoration.collapsed(),
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ],
                              ),
                            )
                          ]),
                      /* first name */
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(
                                    text:     "${AppLocalizations.of(context).translate('beneficiary_first_name')}",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.red))
                                ])),
                            Container(
                              decoration: BoxDecoration(
                                  color: KColors.new_gray,
                                  borderRadius: BorderRadius.circular(5)),
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                      child: TextField(
                                    decoration: InputDecoration.collapsed(),
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ],
                              ),
                            )
                          ]),
                      /* first name */
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                text: TextSpan(
                                    text:     "${AppLocalizations.of(context).translate('beneficiary_mobile_money_account')}",

                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.red))
                                ])),
                            Container(
                              decoration: BoxDecoration(
                                  color: KColors.new_gray,
                                  borderRadius: BorderRadius.circular(5)),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withAlpha(50),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            bottomLeft: Radius.circular(5))),
                                    margin: EdgeInsets.only(right: 15),
                                    child: Text(
                                      "+228",
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  Expanded(
                                      child: TextField(
                                    decoration: InputDecoration.collapsed(),
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  )),
                                ],
                              ),
                            )
                          ]),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Text(
                                  "${AppLocalizations.of(context).translate('mobile_money_only_notice')}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 10, color: KColors.primaryColor),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: this._isAgreed,
                              onChanged: (value) => setState(() {
                                    this._isAgreed = !this._isAgreed;
                                  })),
                          Expanded(
                              child: RichText(
                                  text: TextSpan(
                                      text: "${AppLocalizations.of(context).translate('i_agree_to')}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                      children: [
                                TextSpan(
                                    text: "${AppLocalizations.of(context).translate('terms_n_conditions')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: KColors.new_black,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: "${AppLocalizations.of(context).translate('_and_')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                                TextSpan(
                                    text: "${AppLocalizations.of(context).translate('ppolicy')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: KColors.new_black,
                                        fontWeight: FontWeight.bold))
                              ])))
                        ],
                      ),
                      SizedBox(height: 40,)
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _deleteAccount(),
                    child: Container(
                      width: MediaQuery.of(context).size.width-40,
                      decoration: BoxDecoration(
                          color: KColors.primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      // color: KColors.new_gray,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                /*    Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 10),*/
                                Text(
                                    "${AppLocalizations.of(context).translate('delete_account_button')}"
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _deleteAccount() {}
}
