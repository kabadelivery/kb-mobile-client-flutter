import 'dart:async';

import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../StateContainer.dart';


class RecoverPasswordPage extends StatefulWidget {

  static var routeName = "/RecoverPasswordPage";

  CustomerModel customer;

  RecoverPasswordPresenter presenter;

  bool is_a_process;

  RecoverPasswordPage({Key key, this.presenter, this.is_a_process = false}) : super(key: key);

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> implements RecoverPasswordView {

  List<String> recoverModeHints = [""];

  String _loginFieldHint = "";

  TextEditingController _loginFieldController = new TextEditingController();
  TextEditingController _codeFieldController = new TextEditingController();

  bool isCodeSent = false;
  bool isLoginError = false;
  bool isCodeError = false;

  /* circle loading progressing */
  bool isCodeSending = false;

  int CODE_EXPIRATION_LAPSE = 10*60; /* minutes *  seconds */

  int timeDiff = 0;

  String _requestId;

  @override
  void initState() {
    super.initState();

    this.widget.presenter.recoverPasswordView = this;
    CustomerUtils.getCustomer().then((customer) {
      if (customer != null) {
        xrint("recoverpasswordPage : "+customer.toJson().toString());
        setState(() {
          if (customer.phone_number == null) {
            if (customer.email == null) {
              // check if logged in, if yes, log out...
              xrint("cstomer email is no null");
              CustomerUtils.clearCustomerInformations().whenComplete((){
                StateContainer.of(context).updateLoggingState(state: 0);
                StateContainer.of(context).updateBalance(balance: 0);
                // StateContainer.of(context).updateKabaPoints(kabaPoints: "");
                StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
                StateContainer.of(context).updateTabPosition(tabPosition: 0);
                Navigator.pushNamedAndRemoveUntil(context, SplashPage.routeName, (r) => false);
              });
            } else {
              _loginFieldController.text = customer.email;
            }
          } else
            _loginFieldController.text = customer.phone_number;
        });
      }
    });
    /* retrieve state of the app */
    _retrieveRequestParams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginFieldHint = "${AppLocalizations.of(context).translate('phone_number_hint')}";
    recoverModeHints = ["${AppLocalizations.of(context).translate('recover_password_hint')}",/*"Insert your E-mail address"*/];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          title: Text("${AppLocalizations.of(context).translate('recover_password')}", style:TextStyle(color:KColors.primaryColor)),
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.of(context).maybePop();}),
        ),
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child:Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Icon(Icons.account_circle, size: 80, color: KColors.primaryYellowColor),
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text("${AppLocalizations.of(context).translate('insert_phone_number')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),
                    SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: TextField(controller: _loginFieldController, enabled: widget.is_a_process == true ? false : !isCodeSent, onChanged: _onLoginFieldTextChanged,  maxLength: TextField.noMaxLength, keyboardType: TextInputType.text, decoration: InputDecoration.collapsed(hintText: _loginFieldHint), style: TextStyle(color:Colors.black)),
                            decoration: isLoginError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                        )),

                    SizedBox(height: 30),
                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text("${AppLocalizations.of(context).translate('press_code_hint')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          isCodeSent ?
                          SizedBox(width: 80,
                              child: Container(
                                  padding: EdgeInsets.all(14),
                                  child: TextField(controller: _codeFieldController, maxLength: 4,decoration: InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('code')}"), style: TextStyle(color:KColors.primaryColor), keyboardType: TextInputType.number),
//                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                                  decoration: isCodeError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))
                          ) : Container(),
                          isCodeSent ? SizedBox(width:20) : Container(),
                          OutlineButton(
                              borderSide: BorderSide(
                                color: KColors.primaryColor, //Color of the border
                                style: BorderStyle.solid, //Style of the border
                                width: 0.8, //width of the border
                              ),
                              padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:Colors.white,child: Row(
                            children: <Widget>[
                              Text(isCodeSent && timeDiff != 0 ? "${timeDiff} ${AppLocalizations.of(context).translate('seconds')}" : "${AppLocalizations.of(context).translate('code')}" /* if is code count, we should we can launch a discount */, style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                              /* stream builder, that shows that the code is been sent */
                              isCodeSent == false &&  isCodeSending ? Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(width: 20,height:20,child: CircularProgressIndicator()),
                                ],
                              ) : Container(),
                            ],
                          ), onPressed: () {isCodeSent==false && isCodeSending==false ? _sendCodeAction() : {};}),
                        ]),
                    SizedBox(height: 30),
                    isCodeSent ? MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("${AppLocalizations.of(context).translate('recover_password')}", style: TextStyle(fontSize: 14, color: Colors.white)),
                        SizedBox(width: 10),
                        isCodeSending==true && isCodeSent==true ? SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) : Container(),
                      ],
                    ), onPressed: () {isCodeSent ? _checkCodeAndCreateAccount() : {};}) : Container(),
                  ]
              ),
            ),
          ),
        ));
  }

//  void _handleRadioValueChange (int value) {
//    setState(() {
//      /* clean the content */
//      if (isCodeSent)
//        return;
//      this._loginFieldController.text = "";
//      this._codeFieldController.text = "";
//    });
//  }

  void _sendCodeAction() {

    /* logins */
    String login = _loginFieldController.text;
    /* check the fields */

    /* phone number */

    if (Utils.isPhoneNumber_TGO(login)) {
      this.widget.presenter.sendVerificationCode(login);
      mDialog("${AppLocalizations.of(context).translate('pnumber_registration_code_too_long')}",  is_code_confirmation: true);
    } else if (Utils.isEmailValid(login)) {
      this.widget.presenter.sendVerificationCode(login);
      mDialog("${AppLocalizations.of(context).translate('email_registration_code_too_long')}", is_code_confirmation: true);
    } else {
      /* login error */
      setState(() {
        isLoginError = true;
      });
    }

  }

  _clearSharedPreferences () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("vlcst");
    prefs.remove("vl");
    prefs.remove("vri");
    // prefs.clear();
  }

  _saveRequestParams (String login, String requestId) async {
    /* check the content */
    /* save type of request */
    /* save login */
    /* save start-time */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('vlcst', "${DateTime.now().millisecondsSinceEpoch~/1000}"); /*DateTime.now().*/
    await prefs.setString('vl', login);
    await prefs.setString('vri', requestId);

    this._requestId = requestId;
    _loginFieldController.text = login;
  }

  _retrieveRequestParams () async {

    /* get type of request saved */
    /* get login */
    /* get start-time */

    String login;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tmp = prefs.getString("vlcst");
    login = prefs.getString("vl");

    DateTime lastCodeSentDatetime = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      lastCodeSentDatetime = DateTime.fromMillisecondsSinceEpoch(int.parse(tmp)*1000);
    } catch (_) {
      xrint("ERROR");
      return;
    }

    _loginFieldController.text = login;

    if (DateTime.now().isBefore(lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {

      /* if code sent, do something else,  */
      isCodeSent = true;
      this._requestId = prefs.getString("vri");
      _loginFieldController.text = prefs.getString("vl");

      mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (DateTime.now().isAfter(lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {
          setState(() {
            isCodeSent = false;
          });
          _clearSharedPreferences();
          timer.cancel();
        } else {
          /* update text;;; if codeIsSent */
          setState(() {
            /* convert into minutes, and show it */
            Duration duration = lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)).difference(DateTime.now());
            timeDiff = duration.inSeconds;
          });
        }
      });
    }
  }

  Timer mainTimer;

  @override
  void dispose() {
    try {
      mainTimer.cancel();
    } catch(_) {
      xrint(_);
    }
    super.dispose();
  }


  void _onLoginFieldTextChanged(String value) {
    setState(() {
      isLoginError = false;
    });
  }



  void mToast(String message) {
//    Toast.show(message, context, duration: Toast.LENGTH_LONG);
    mDialog(message);
  }

  @override
  Future codeIsOk(bool isOk) async {

    /* jump to setup code activity */
    setState(() {
      isCodeSending = false;
    });
    String _mCode1, _mCode2;
    if (isOk) {
      /* clear shared preferences */
      _clearSharedPreferences();
      var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return new RetrievePasswordPage(type: 1);
        },
      ));
      if (results != null && results.containsKey('code') && results.containsKey('type')) {
        _mCode1 = results['code'];
        int type = results['type'];
        /* launch confirmation */
        _mCode2 = "";
        do {
          var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              return new RetrievePasswordPage(type: 2);
            },
          ));
          if (results != null && results.containsKey('code') && results.containsKey('type')) {
            _mCode2 = results['code'];
          }
        } while (_mCode1 != _mCode2);
      }

      /* launch create account request, and if success*/
      widget.presenter.updatePassword(_loginFieldController.text, _mCode1, _requestId);
      /*this.widget.presenter.createAccount(nickname: _nicknameFieldController.text, password: _mCode1,
          phone_number: Utils.isPhoneNumber_TGO(_loginFieldController.text) ? _loginFieldController.text : "",
          email: Utils.isEmailValid(_loginFieldController.text) ? _loginFieldController.text : "",
          request_id: this._requestId
      );*/
    }
  }

  @override
  void disableCodeButton(bool isDisabled) {
  }

  @override
  void keepRequestId(String login, String requestId) {
    /* save the id somewhere in my .... */
    xrint("request Id ${requestId}");

    this._requestId = requestId;
    /* start minute-count of the seconds into the message thing */
    _saveRequestParams(login, requestId);
    _retrieveRequestParams();
    setState(() {
      isCodeSent = true;
    });
  }

  @override
  void onNetworkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  @override
  void onSysError({String message = ""}) {
    mToast(message);
  }

  @override
  void showLoading(bool isLoading) {

  }

  @override
  void toast(String message) {
    mToast(message);
  }

  @override
  void userExistsAlready() {
//    mToast("user Exists Already");
  }


  _checkCodeAndCreateAccount() {

    /* check request id and the code */
    String _code = _codeFieldController.text;
    if (Utils.isCode(_code)) {
      setState(() {
        isCodeSending = false;
      });
      this.widget.presenter.checkVerificationCode(
          _codeFieldController.text, this._requestId);
    } else {
      mToast("${AppLocalizations.of(context).translate('wrong_code')}");
    }
  }

  @override
  void sendVerificationCodeLoading(bool isLoading) {
    setState(() {
      isCodeSending = isLoading;
    });
  }

  @override
  void recoverFails() {
    mToast("${AppLocalizations.of(context).translate('password_recover_fails')}");
  }

  @override
  void recoverSuccess(String phoneNumber, String newCode) {
    /* send to login page and */
    mToast("${AppLocalizations.of(context).translate(
        'password_updated_success')}");

    if (!widget.is_a_process) {
      // logout.
      StateContainer
          .of(context)
          .balance = 0;
      CustomerUtils.clearCustomerInformations().whenComplete(() {
        StateContainer.of(context).updateBalance(balance: 0);
        // StateContainer.of(context).updateKabaPoints(kabaPoints: "");
        StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
        StateContainer.of(context).updateTabPosition(tabPosition: 0);

        Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
                LoginPage(presenter: LoginPresenter(),
                    phone_number: phoneNumber,
                    password: newCode,
                    autoLogin: true)), (r) => false);
      });
    }
  }

  void mDialog(String message, {bool is_code_confirmation = false}) {

    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
        is_code_confirmation : is_code_confirmation
    );
  }

  void _showDialog(
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, bool is_code_confirmation}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        svgIcons,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.is_a_process && is_code_confirmation == false)
                    Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }


}
