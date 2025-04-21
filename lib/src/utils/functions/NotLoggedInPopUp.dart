import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../StateContainer.dart';
import '../../contracts/login_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../../ui/screens/auth/login/LoginPage.dart';
import '../../utils/_static_data/ImageAssets.dart';
void NotLoggedInPopUp(BuildContext context){
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
            "${AppLocalizations.of(context)!.translate('please_login_before_going_forward_title')}"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              /* add an image*/
              // location_permission
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                      image: new DecorationImage(
                        fit: BoxFit.fitHeight,
                        image:
                        new AssetImage(ImageAssets.login_description),
                      ))),
              SizedBox(height: 10),
              Text(
                  "${AppLocalizations.of(context)!.translate("please_login_before_going_forward_description_place_order")}",
                  textAlign: TextAlign.center)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
                "${AppLocalizations.of(context)!.translate('not_now')}"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child:
            Text("${AppLocalizations.of(context)!.translate('login')}"),
            onPressed: () {
              /* */
              /* jump to login page... */
              Navigator.of(context).pop();

              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage(
                      presenter: LoginPresenter(LoginView()),
                      fromOrderingProcess: true)));
            },
          )
        ],
      );
    },
  );
}