import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ErrorPage extends StatelessWidget {

  static const TYPE_NO_NETWORK = -20;
  static const TYPE_SYSTEM_BROKEN = -21;

  int type = TYPE_SYSTEM_BROKEN;

  var onClickAction;

  String message;

  ErrorPage({
    Key key,
    this.type,
    this.onClickAction,
    this.message,
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: (
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /* text / image
                    * button */
                SizedBox(width: 40, height: 40,
                    child: IconButton(icon: Icon(Icons.error, color: KColors.primaryColor))),
                SizedBox(height: 5),
                Container(margin: EdgeInsets.only(left:10, right: 10),child: Text(message, textAlign: TextAlign.center)),
                SizedBox(height:10),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    child:Text("${AppLocalizations.of(context)?.translate('try_again')}",
                    style: TextStyle(color: Colors.white)),
                    onPressed: onClickAction, color: KColors.primaryColor)
              ])
      ),
    );
  }



}