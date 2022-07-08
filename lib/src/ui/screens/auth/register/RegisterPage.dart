import 'dart:async';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/xrint.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class RegisterPage extends StatefulWidget {

  static var routeName = "/RegisterPage";

  final RegisterPresenter presenter;

  final String login;

  RegisterPage({Key key, this.presenter, this.title, this.login}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> implements RegisterView {

  int _registerModeRadioValue = 0;

  List<String> recoverModeHints = ["",""];
  /*"Insert your E-main address"*/

  List<String> _loginFieldHint;

  String _nicknameFieldHint;
  String _whatsappPhoneNumberHint;

  List<TextInputType> _loginFieldInputType = [TextInputType.emailAddress, TextInputType.emailAddress];

  List<int> _loginMaxLength = [8,100];

  TextEditingController _loginFieldController = new TextEditingController();
  TextEditingController _codeFieldController = new TextEditingController();
  TextEditingController _nicknameFieldController = new TextEditingController();
  TextEditingController _whatsappPhonenumberController = new TextEditingController();

  bool isCodeSent = false;
  bool isLoginError = false;
  bool isEmailError = false;
  bool isCodeError = false;
  bool isNicknameError = false;
  bool isWhaNumberError = false;

  /* circle loading progressing */
  bool isCodeSending = false;
  bool isAccountCreating = false;

  int CODE_EXPIRATION_LAPSE = 10*60; /* minutes *  seconds */
  int timeDiff = 0;

  String _requestId;

  bool isAccountRegistering = false;

  String _initialSelection = "FR";

  @override
  void initState() {
    super.initState();

    recoverModeHints = [""];
    _loginFieldHint = [""];
    _nicknameFieldHint = "";
    _whatsappPhoneNumberHint = "";

    this.widget.presenter.registerView = this;
    /* retrieve state of the app */
    _retrieveRequestParams();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    recoverModeHints = ["${AppLocalizations.of(context).translate('new_account_phonenumber_hint')}", "${AppLocalizations.of(context).translate('new_account_email_hint')}"];
    _loginFieldHint = ["${AppLocalizations.of(context).translate('phone_number_hint')}", "xxxxxx@yyy.zzz"];
    _nicknameFieldHint = "${AppLocalizations.of(context).translate('nickname')}";
    _whatsappPhoneNumberHint = "${AppLocalizations.of(context).translate('whatsapp_number_hint')}";

    if (widget.login != null && _loginFieldController != null) {
      if (Utils.isEmailValid(widget.login)) {
          _handleRadioValueChange(1);
      } else {
        _handleRadioValueChange(0);
      }
      _loginFieldController?.text = widget.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          title: Text("${AppLocalizations.of(context).translate('register')}", style:TextStyle(color:KColors.primaryColor)),
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
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
                    Text("CREATE ACCOUNT", style:TextStyle(color:KColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                    Icon(Icons.account_circle, size: 80, color: KColors.primaryYellowColor),
                    /* radiobutton - check who are you */
                    !isCodeSent ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Radio(
                            value: 0,
                            groupValue: _registerModeRadioValue,
                            onChanged: _handleRadioValueChange,
                          ), new Text(
                              'Phone',
                              style: new TextStyle(fontSize: 16.0)),
                          new Radio(
                            value: 1,
                            groupValue: _registerModeRadioValue,
                            onChanged: _handleRadioValueChange,
                          ), new Text(
                              'E-main',
                              style: new TextStyle(fontSize: 16.0)),
                        ]) : Container(),
                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(recoverModeHints[_registerModeRadioValue], textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),

                    SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: TextField(controller: _loginFieldController,
                                enabled: !isCodeSent,
                                onChanged: _onLoginFieldTextChanged,  maxLength: _registerModeRadioValue == 0 ? 8 : TextField.noMaxLength, keyboardType: _registerModeRadioValue == 0 ? TextInputType.emailAddress : TextInputType.emailAddress, decoration: InputDecoration.collapsed(hintText: _loginFieldHint[_registerModeRadioValue]), style: TextStyle(color:Colors.black)),
                            decoration: isLoginError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                        )),


                    SizedBox(height: 10),
                    SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: TextField(controller: _nicknameFieldController,
                                enabled: !isCodeSent,
                                onChanged: _onNicknameFieldTextChanged,
                                decoration: InputDecoration.collapsed(hintText: _nicknameFieldHint), style: TextStyle(color:Colors.black),
                                keyboardType: TextInputType.emailAddress),
                            decoration:  isNicknameError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                        )),
                    _registerModeRadioValue == 1 ? SizedBox(height: 20) : Container(),

                    _registerModeRadioValue == 1 ? Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(
                        "${AppLocalizations.of(context).translate('please_enter_whatsapp_no')}",
                        textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)) : Container(),
                    _registerModeRadioValue == 1 ?  SizedBox(height: 10) : Container(),

                    _registerModeRadioValue == 1 /* email */ ?
                    Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryCodePicker(
                          flagWidth: 16,
                          onChanged: _onCountryChanged,
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: _initialSelection,
                          // favorite: ['+33','FR'],
                          // optional. Shows only country name and flag
                          showCountryOnly: false,
                          // optional. Shows only country name and flag when popup is closed.
                          showOnlyCountryWhenClosed: false,
                          // optional. aligns the flag and the Text left
                          alignLeft: false,
                        )
                         ,
                        SizedBox(width: 160,
                            child: Container(
                                padding: EdgeInsets.all(14),
                                child: TextField(controller: _whatsappPhonenumberController,
                                    enabled: !isCodeSent,
                                    onChanged: _onWhaNumberieldTextChanged,
                                    decoration: InputDecoration.collapsed(hintText: _whatsappPhoneNumberHint), style: TextStyle(color:Colors.black),
                                    keyboardType: TextInputType.emailAddress),
                                decoration:  isWhaNumberError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                            )),
                      ],
                    )
                        : Container(),

                    SizedBox(height: 30),
                    (isCodeSending==true && isCodeSent==true) || (isAccountRegistering) ?
                    SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor)),
                        height: 15, width: 15) : Container(),

                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(
                        "${AppLocalizations.of(context).translate('press_code_hint')}",
                        textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          isCodeSent ?
                          SizedBox(width: 80,
                              child: Container(
                                  padding: EdgeInsets.all(14),
                                  child: TextField(controller: _codeFieldController, maxLength: 4,decoration: InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('code')}"), style: TextStyle(color:Colors.black), keyboardType: TextInputType.number),
//                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                                  decoration: isCodeError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))
                          ) : Container(),
                          isCodeSent ? SizedBox(width:20) : Container(),
                          OutlinedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white),padding: MaterialStateProperty.all(EdgeInsets.only(top:15, bottom:15, left:10, right:10)),side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 0.8))),
                              child: Row(
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
                        Text("${AppLocalizations.of(context).translate('register')}", style: TextStyle(fontSize: 14, color: Colors.white)),
                        SizedBox(width: 10),
                        (isCodeSending==true && isCodeSent==true) || (isAccountRegistering) ? SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) : Container(),
                      ],
                    ), onPressed: () {isCodeSent ? _checkCodeAndCreateAccount() : {};}) : Container(),
                    SizedBox(height: 50),
                  ]
              ),
            ),
          ),
        ));
  }

  void _handleRadioValueChange (int value) {
    setState(() {
      /* clean the content */
      if (isCodeSent)
        return;
      this._registerModeRadioValue = value;
      this._loginFieldController.text = "";
      this._codeFieldController.text = "";
    });
  }

  void _sendCodeAction() {

    /* logins */
    String login = _loginFieldController.text;
    /* check the fields */
    if (_registerModeRadioValue == 0) {
      /* phone number */
      String phoneNumber = login;
      if (!Utils.isPhoneNumber_TGO(phoneNumber)) {
        setState(() {
          isLoginError = true;
        });
        return;
      }
    } else {
      /* email */
      String email = login;
      if (!Utils.isEmailValid(email)) {
        setState(() {
          isLoginError = true;
        });
        return;
      }
    }

    /* nicknames */
    String _nickname = _nicknameFieldController.text;
    /* check the fields */
    if (_nickname.trim().length==0) {
      setState(() {
        isNicknameError = true;
      });
      return;
    }

    setState(() {
      isCodeSending = true;
    });
    /* send request, to the server, and if ok, save request params and update fields. */
    ////////////////////////////// userDataBloc.sendRegisterCode(login: login);
    this.widget.presenter.sendVerificationCode(login);


   /*
    if (_registerModeRadioValue == 0) {
      // phone number
      mDialog("${AppLocalizations.of(context).translate('pnumber_registration_code_too_long')}");
    } else if (_registerModeRadioValue == 1) {
      // email...
      *//* if email, tell customer that the message could hide into the spams. *//*
      // mailbox
      mDialog("${AppLocalizations.of(context).translate('email_registration_code_too_long')}");
    }*/
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  _clearSharedPreferences () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("register_type");
    prefs.remove("whatsapp_number_area_code");
    prefs.remove("whatsapp_number_id");
    prefs.remove("whatsapp_number_no");
    prefs.remove("last_code_sent_time");
    prefs.remove("login");
    prefs.remove("request_id");
    // prefs.clear();
  }

  Future<void> _saveRequestParams (String login, String requestId) async {
    /* check the content */
    /* save type of request */
    /* save login */
    /* save start-time */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('register_type', _registerModeRadioValue);
    await prefs.setString('last_code_sent_time', "${DateTime.now().millisecondsSinceEpoch~/1000}"); /*DateTime.now().*/
    await prefs.setString('login', login);
    await prefs.setString('nickname', _nicknameFieldController.text);
    await prefs.setString('request_id', requestId);

    if (_registerModeRadioValue == 1) {
      // String whatsapp_number = "${countryDialCode.substring(1)}${_whatsappPhonenumberController.text}"; // append entered phone number
      await prefs.setString('whatsapp_number_id', "${countryDialCode.code}"); // FR
      await prefs.setString('whatsapp_number_area_code', "${countryDialCode.dialCode}"); //33
      await prefs.setString('whatsapp_number_no', "${_whatsappPhonenumberController.text}");
    }

    this._requestId = requestId;
  }

  _retrieveRequestParams () async {

    /* get type of request saved */
    /* get login */
    /* get start-time */

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tmp = prefs.getString("last_code_sent_time");

//    if (!(registerType != null && registerType >= 0 && registerType < recoverModeHints.length))
//      return;

    DateTime lastCodeSentDatetime = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      lastCodeSentDatetime = DateTime.fromMillisecondsSinceEpoch(int.parse(tmp)*1000);
    } catch (_) {
      xrint("ERROR");
      return;
    }

//    _registerModeRadioValue = registerType;

    if (DateTime.now().isBefore(lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {


      int register_type = prefs.getInt("register_type");

      setState(() {
        /* if code sent, do something else,  */
        isCodeSent = true;
        this._requestId = prefs.getString("request_id");
        _loginFieldController.text = prefs.getString("login");
        _nicknameFieldController.text = prefs.getString("nickname");
        _registerModeRadioValue = register_type;
      });


      if (register_type == 1) {

        String whatsapp_number_id = prefs.getString("whatsapp_number_id"); // FR
        String whatsapp_number_no = prefs.getString("whatsapp_number_no");
        String whatsapp_number_area_code = prefs.getString("whatsapp_number_area_code"); // 33

        countryDialCode = CountryCode(code: whatsapp_number_id, dialCode: whatsapp_number_area_code);

        setState(() {
        // whatsapp no
        _whatsappPhonenumberController.text = whatsapp_number_no;
        // whatsapp id
        _initialSelection = whatsapp_number_id;
        });
      }

      /* make a second-ly second discount for the registration */
      mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (DateTime.now().isAfter(lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {
          xrint("time has ellapsed;");
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
    } else {
      xrint("time has not yet ellapsed;");
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

  void _onNicknameFieldTextChanged (String value) {
    setState(() {
      isNicknameError = false;
    });
  }

  void _onWhaNumberieldTextChanged (String value) {
    setState(() {
      isWhaNumberError = false;
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

      setState(() {
        isAccountRegistering = true;
      });

      String whatsapp_number = "${countryDialCode?.dialCode}${_whatsappPhonenumberController.text}"; // append entered phone number

      xrint("whatsappNo ${whatsapp_number}");

      /* launch create account request, and if success*/
      this.widget.presenter.createAccount(nickname: _nicknameFieldController.text, password: _mCode1,
          phone_number: Utils.isPhoneNumber_TGO(_loginFieldController.text) ? _loginFieldController.text : "",
          email: Utils.isEmailValid(_loginFieldController.text) ? _loginFieldController.text : "",
          request_id: this._requestId, whatsapp_number: whatsapp_number
      );
    }
  }

  @override
  void disableCodeButton(bool isDisabled) {
  }

  @override
  void keepRequestId(String login, String requestId) {
    /* save the id somewhere in my .... */
    this._requestId = requestId;
    /* start minute-count of the seconds into the message thing */
    _saveRequestParams(login, requestId).then((value) {
      _retrieveRequestParams();
    });

    // inform the client to remain patient until he gets the code
    if (_registerModeRadioValue == 0) {
      // phone number
      mDialog("${AppLocalizations.of(context).translate('pnumber_registration_code_too_long')}");
    } else if (_registerModeRadioValue == 1) {
      // email...
      /* if email, tell customer that the message could hide into the spams. */
      // mailbox
      mDialog("${AppLocalizations.of(context).translate('email_registration_code_too_long')}");
    }
  }

  @override
  void onNetworkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  @override
  void onSysError({String message = "Sys error"}) {
    mToast(message);
  }

  @override
  void registerSuccess(String phone_number, String password) {
    /*  */
    Toast.show("${AppLocalizations.of(context).translate('account_created_successfully')}", context, duration: Toast.LENGTH_LONG);
    Navigator.of(context).pop({'phone_number':phone_number, 'password':password, 'autologin': true});
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isCodeSending = isLoading;
    });
  }

  @override
  void toast(String message) {
    mToast(message);
  }

  @override
  void userExistsAlready() {
    mDialog("${AppLocalizations.of(context).translate('user_exists')}");
  }

  @override
  void codeRequestSentOk() {
    setState(() {
      isCodeSending = false;
    });
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



  void _showDialog(
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
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
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 1))),
                  child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }

  @override
  void codeError() {
    mToast("${AppLocalizations.of(context).translate('register_code_error')}");
  }


  CountryCode countryDialCode = CountryCode(code: "FR", dialCode: "33");

  void _onCountryChanged(CountryCode value) {
     countryDialCode = value;
     _initialSelection = value.code;
  }


}
