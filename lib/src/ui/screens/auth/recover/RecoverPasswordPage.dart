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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../StateContainer.dart';
import '../../../../resources/login_provider.dart';
import '../recover/NewPasswordPage.dart';

class RecoverPasswordPage extends ConsumerStatefulWidget {

  static var routeName = "/RecoverPasswordPage";

  CustomerModel? customer;

  RecoverPasswordPresenter? presenter;

  bool? is_a_process;

  RecoverPasswordPage({Key? key, this.presenter, this.is_a_process = false}) : super(key: key);

  @override
  ConsumerState<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends ConsumerState<RecoverPasswordPage> implements RecoverPasswordView {

  List<String> recoverModeHints = [""];

  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(4, (_) => FocusNode());


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

  String? _requestId;



  @override
  void initState() {
    super.initState();

    this.widget.presenter!.recoverPasswordView = this;
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
                // StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
                StateContainer.of(context).hasUnreadMessage = false;
                StateContainer.of(context).updateTabPosition(tabPosition: 0);
                Navigator.pushNamedAndRemoveUntil(context, SplashPage.routeName, (r) => false);
              });
            } else {
              _loginFieldController.text = customer.email!;
            }
          } else
            _loginFieldController.text = customer.phone_number!;
        });
      }
    });
    /* retrieve state of the app */
    _retrieveRequestParams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginFieldHint = "${AppLocalizations.of(context)!.translate('phone_number_hint')}";
    recoverModeHints = ["${AppLocalizations.of(context)!.translate('recover_password_hint')}",/*"Insert your E-mail address"*/];
  }

  @override
  Widget build(BuildContext context) {
    final raw = ref.watch(loginProvider).trim();
    String login = raw.contains('@') ? raw : raw.startsWith('+') ? raw.substring(1) : "228$raw";
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: KColors.primaryColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('input_password')}"),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child:Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(FontAwesomeIcons.rightFromBracket,
                            color: KColors.primaryColor, size: 25),
                        SizedBox(width: 20),
                        Text("Connexion",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 30),


                    SizedBox(height: 10),
                    SizedBox(height: 10),
                   // Container(margin: EdgeInsets.only(left:40, right: 40),child: Text("${AppLocalizations.of(context)!.translate('insert_phone_number')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    Container(
                        margin: EdgeInsets.only(left:40, right: 40),child: Text("Vous allez Recevoir un  code OTP sur :", textAlign: TextAlign.center,   style: const TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
                    )),
                    SizedBox(height: 10),
                    Text(
                        Utils.isEmailValid(ref.watch(loginProvider))
                            ? login                              // If email → display as-is
                            : login.startsWith('+')
                            ? login.substring(1)             // Remove "+" if exists
                            : "$login"                    // Add prefix only for phone
                    ),
                   /* SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: Text(ref.watch(loginProvider)),
                            //TextField(controller: _loginFieldController, enabled: widget.is_a_process == true ? false : !isCodeSent, onChanged: _onLoginFieldTextChanged,  maxLength: TextField.noMaxLength, keyboardType: TextInputType.text, decoration: InputDecoration.collapsed(hintText: _loginFieldHint), style: TextStyle(color:KColors.new_black)),
                            decoration: isLoginError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                        )),*/
                    //Container(margin: EdgeInsets.only(left:40, right: 40),child: Text("${AppLocalizations.of(context)!.translate('press_code_hint')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // ---------------- OTP FIELDS LINE ----------------
                      if (isCodeSent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _buildOtpField(index),
                            ),
                          ),
                        ),

                      if (isCodeSent) const SizedBox(height: 20),

                      // ---------------- BUTTON LINE ----------------
                      SizedBox(
                        width: 160, // medium size, not too big, not too small
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: KColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: KColors.primaryColor, width: 1.5),
                          ),
                          onPressed: () {
                            if (!isCodeSent && !isCodeSending) _sendCodeAction();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isCodeSent && timeDiff != 0
                                    ? "$timeDiff ${AppLocalizations.of(context)!.translate('seconds')}"
                                    : AppLocalizations.of(context)!.translate('code'),
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),

                              if (!isCodeSent && isCodeSending)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 30),
                    isCodeSent ? MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("${AppLocalizations.of(context)!.translate('recover_password')}", style: TextStyle(fontSize: 14, color: Colors.white)),
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

    /* check the fields */

    //String login = ref.watch(loginProvider).startsWith('+') ? ref.watch(loginProvider).substring(1) : "228${ref.watch(loginProvider)} " : Utils.isEmailValid(email);
    final raw = ref.watch(loginProvider).trim();
    String login = raw.contains('@') ? raw : raw.startsWith('+') ? raw.substring(1) : "228$raw";
    if (login.isNotEmpty) {
      this.widget.presenter!.sendVerificationCode(login);
      mDialog("${AppLocalizations.of(context)!.translate('pnumber_registration_code_too_long')}",  is_code_confirmation: true);
    } else if (Utils.isEmailValid(login)) {
      this.widget.presenter!.sendVerificationCode(login);
      mDialog("${AppLocalizations.of(context)!.translate('email_registration_code_too_long')}", is_code_confirmation: true);
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
    String tmp = prefs.getString("vlcst")!;
    login = await prefs.getString("vl")??"";

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
      _loginFieldController.text = prefs.getString("vl")??"";

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

  Timer? mainTimer;

  @override
  void dispose() {
    try {
      mainTimer!.cancel();
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
    // Stop loading
    setState(() {
      isCodeSending = false;
    });

    if (!isOk) return;

    // Clear shared preferences
    _clearSharedPreferences();

    // Call RetrievePasswordPage once
    final result = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NewPasswordPage(type:0),
      ),
    );

    if (result == null || !result.containsKey('code')) return;

    final String newPassword = result['code'];

    // Update password
    widget.presenter!.updatePassword(
      _loginFieldController.text,
      newPassword,
      _requestId!,
    );
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
    mToast("${AppLocalizations.of(context)!.translate('network_error')}");
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
    String _code = _controllers.map((c) => c.text).join();
    if (Utils.isCode(_code)) {
      setState(() {
        isCodeSending = false;
      });
      this.widget.presenter!.checkVerificationCode(
          _code, this._requestId!);
    } else {
      mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
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
    mToast("${AppLocalizations.of(context)!.translate('password_recover_fails')}");
  }

  @override
  void recoverSuccess(String phoneNumber, String newCode) {
    /* send to login page and */
    mToast("${AppLocalizations.of(context)!.translate(
        'password_updated_success')}");

    if (!widget.is_a_process!) {
      // logout.
      StateContainer
          .of(context)
          .balance = 0;
      CustomerUtils.clearCustomerInformations().whenComplete(() {
        StateContainer.of(context).updateBalance(balance: 0);
        // StateContainer.of(context).updateKabaPoints(kabaPoints: "");
        // StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
        StateContainer.of(context).hasUnreadMessage = false;
        StateContainer.of(context).updateTabPosition(tabPosition: 0);
              String cleaned = phoneNumber.contains('@') ? phoneNumber : phoneNumber.substring(3) ;
        Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
                LoginPage(presenter: LoginPresenter(LoginView()),
                    phone_number: cleaned ,
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
      {String? svgIcons, Icon? icon, var message, bool okBackToHome = false, bool isYesOrNo = false, bool? is_code_confirmation}) {
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
                        svgIcons!,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text("${AppLocalizations.of(context)!.translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ] : <Widget>[
              //
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.is_a_process! && is_code_confirmation == false)
                    Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }

        },
      ),
    );
  }


}