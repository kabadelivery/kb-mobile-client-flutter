import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class ConfirmLoginPage extends StatefulWidget {

  static var routeName = "/ConfirmLoginPage";

  int type;

  ConfirmLoginPage({Key key, this.type=1}) : super(key: key){}

  @override
  _ConfirmLoginPageState createState() => _ConfirmLoginPageState();
}

class _ConfirmLoginPageState extends State<ConfirmLoginPage> {

  String hint;

  TextEditingController _loginFieldController;
  TextEditingController _codeFieldController;

  bool isCodeError = false;

  var _registerModeRadioValue;

  bool isLoginError = false;

  bool isCodeSent = false;

  var _loginFieldInputType;

  @override
  void initState() {
    super.initState();
    _loginFieldController = TextEditingController();
    _codeFieldController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hint = "${AppLocalizations.of(context)!.translate('_confirm')} ${widget.type == 1 ? "${AppLocalizations.of(context)!.translate('phone_number')}" : "${AppLocalizations.of(context)!.translate('email')}" }";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text("${AppLocalizations.of(context)!.translate('_confirm')}", style:TextStyle(color:KColors.primaryColor))),
      body: Container(
        child: SingleChildScrollView(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(hint, textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                  SizedBox(height: 30),
                  /* field that says insert the login. */
            Row( mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
              SizedBox(width: 250,
                  child: Container(
                      padding: EdgeInsets.all(14),
                      child: TextField(controller: _loginFieldController, enabled: !isCodeSent, decoration: InputDecoration.collapsed(hintText: hint), style: TextStyle(color:KColors.primaryColor)),
                      decoration: isLoginError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                  )),

            ]),
                  SizedBox(height: 30),
                  SizedBox(width: 80,
                      child: Container(
                          padding: EdgeInsets.all(14),
                          child: TextField(controller: _codeFieldController, maxLength: 4,decoration: InputDecoration.collapsed(hintText: "CODE"), style: TextStyle(color:KColors.primaryColor), keyboardType: TextInputType.number),
                          decoration: isCodeError ? BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))
                  )
                ])),
      ),
    );
  }
}
