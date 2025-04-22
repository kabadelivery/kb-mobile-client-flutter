import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  static const TYPE_NO_NETWORK = -20;
  static const TYPE_SYSTEM_BROKEN = -21;

  int? type = TYPE_SYSTEM_BROKEN;

  var onClickAction;

  String? message;

  double? error_text_font_size;

  ErrorPage({
    Key? key,
    this.type,
    this.error_text_font_size = 14,
    this.onClickAction,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: (Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /* text / image
                    * button */
            SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                    icon: Icon(Icons.error, color: KColors.primaryColor), onPressed: () {  },)),
            message != "" ? SizedBox(height: 5) : Container(),
            message != ""
                ? Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Text(message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: error_text_font_size)))
                : Container(),
            SizedBox(height: 10),
            MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    Utils.capitalize(
                        "${AppLocalizations.of(context)?.translate('try_again')}"),
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                onPressed: onClickAction,
                color: KColors.primaryColor)
          ])),
    );
  }
}
