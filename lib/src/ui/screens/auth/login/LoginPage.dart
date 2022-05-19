import 'dart:convert';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginOTPConfirmationPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


const String DEMO_ACCOUNT_USERNAME = "90000000";

class LoginPage extends StatefulWidget {

  static var routeName = "/LoginPage";

  LoginPresenter presenter;

  bool autoLogin = false;

  String phone_number, password;

  String version;

  bool fromOrderingProcess;

  LoginPage({Key key, this.title, this.presenter, this.phone_number, this.password, this.autoLogin = false, this.fromOrderingProcess = false}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginView {

  String hint = "";

  bool isConnecting = false;

  TextEditingController _loginFieldController = new TextEditingController();



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hint = "${AppLocalizations.of(context).translate('login_phonenumber_hint')}";
  }

  @override
  Future<void> initState() {
    super.initState();
    this.widget.presenter.loginView = this;

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        widget.version = packageInfo.version;
      });
    });

    _getIsOkWithTerms().then((isOkWithTerms){
      if (!isOkWithTerms) {
        // jump to terms page.
        _askTerms();
      }
    });

    if (widget?.autoLogin == true) {
      _loginFieldController.text = widget.phone_number;
      if ((Utils.isPhoneNumber_TGO(widget.phone_number) || Utils.isEmailValid(widget.phone_number)) && widget?.password?.length == 4)
        widget.presenter.login(false/*bcs autologin*/, widget.phone_number, widget.password, widget.version);
    } else {
      // we dont do any another login here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SingleChildScrollView(
            child:Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 80),
                    Text("${AppLocalizations.of(context).translate('connexion')}", style:TextStyle(color:KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 100),
                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(hint, textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 30),
                    SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: TextField(controller: _loginFieldController, enabled: !isConnecting, maxLength: TextField.noMaxLength, keyboardType: TextInputType.text, decoration:
                            InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('identifier')}"), style: TextStyle(color:Colors.black)),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))),
                    SizedBox(height: 30),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                            children: <Widget>[
                              Text("${AppLocalizations.of(context).translate('connexion')}", style: TextStyle(fontSize: 14, color: Colors.white)),
                              isConnecting ?  Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15),
                                ],
                              )  : Container(),
                            ],
                          ), onPressed: () {_launchConnexion();}),
                          SizedBox(width:20),
                          MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:KColors.primaryYellowColor,child: Text("${AppLocalizations.of(context).translate('register')}", style: TextStyle(fontSize: 14, color: Colors.white)), onPressed: () {_moveToRegisterPage(null);}),
                        ]),
                    SizedBox(height: 30),
                    Center(
                      child: InkWell(
                        child:Row(mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.questionCircle, color: Colors.grey),
                            SizedBox(width: 5),
                            Text("${AppLocalizations.of(context).translate('recover_password')} ?", style: KStyles.hintTextStyle_gray),
                          ],
                        ),
                        onTap: (){_moveToRecoverPasswordPage();},
                      ),
                    ),
                    SizedBox(height: 50),
                  ]
              ),
            ),
          ),
        ));
  }

  Future<void> _moveToRegisterPage(String login) async {

    /*  Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage (presenter: RegisterPresenter()),
      ),
    );*/

    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            RegisterPage (presenter: RegisterPresenter(), login: login),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));

    if (results != null && results.containsKey('phone_number') && results.containsKey('password')
        && results.containsKey('autologin')) {
      setState(() {
        _loginFieldController.text = results['phone_number'];
      });
      showLoading(true);
      // launch request for retrieving the delivery prices and so on.
      if (results['autologin'] == true){
        widget.autoLogin = true;
      }
      widget.presenter.login(false, results['phone_number'], results['password'], widget.version);
    }
  }

  void _moveToRecoverPasswordPage() {

    Navigator.of(context).pushReplacement(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
//            RegisterPage (presenter: RegisterPresenter()),
        RecoverPasswordPage(presenter: RecoverPasswordPresenter()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));


  }

  Future _launchConnexion() async {

    String login = _loginFieldController.text;

    // control login stuff
    if (!(Utils.isEmailValid(login) || Utils.isPhoneNumber_TGO(login))) {
      /* login error */
      mToast("${AppLocalizations.of(context).translate('login_error')}");
      return;
    }

    // 1. get password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return RetrievePasswordPage(type: 0);
        }
    ));

    if (results != null && results.containsKey('code') && results.containsKey('type')) {
      String _mCode = results['code'];
//      int type = results['type'];
      showLoading(true);
      if (Utils.isCode(_mCode)) {
        /* check if it's important to send another sms according to the time lapsed after the last sending
      * 1. check last time sent message, if before 5 minutes, then dont send,
      * 2. otherwise send
      *  */
        CustomerUtils.getLastValidOtp(username: login).then((otp) {
          if ("no".compareTo(otp) == 0) {

            if (login.compareTo(DEMO_ACCOUNT_USERNAME) == 0 || XRINT_DEBUG_VALUE == true) {
              widget.autoLogin = true;
              this.widget.presenter.login(false, login, _mCode, widget.version);
            } else
              this.widget.presenter.login(true, login, _mCode, widget.version);

          } else {
            this.widget.presenter.login(false, login, _mCode, widget.version);
          }
        });
      }
    }
  }

  @override
  void loginFailure(String message) {
    mToast(message);
    showLoading(false);
  }

  @override
  Future<void> loginSuccess(dynamic obj) async {

    CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);

    String otp = null;

    if (!widget?.autoLogin) {
      /* retrieve the otp and save it for later use */
      try {
        if (obj["login_code"] != null)
          otp = "${obj["login_code"]}";
      } catch (_) {
        otp = null;
      }
      /* save it to the shared preferences */
      if (otp != null) {
        CustomerUtils.saveOtpToSharedPreference(customer?.username,otp);
        await nextStepWithOtpConfirmationPage(customer, otp, obj);
      } else {
        CustomerUtils.getLastOtp(customer?.username).then((mOtp) async {
          // this is the otp
          if ("no".compareTo(mOtp) == 0) {
            // login_failure
            showLoading(false);
          } else {
            /* if you are coming from another process like already making an order, then just pop */
            /* token must be saved by now. */
            await nextStepWithOtpConfirmationPage(customer, mOtp, obj);
          }
        });
      }
    } else {
      // go directly
      await nextStepWithOtpConfirmationPage(customer, "", obj);
    }
  }

  Future<void> nextStepWithOtpConfirmationPage(CustomerModel customer, String mOtp, dynamic obj) async {


    /* if you are coming from another process like already making an order, then just pop */
    /* token must be saved by now. */
    showLoading(false);

    Map results = Map();

    if ("${customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) == 0 || XRINT_DEBUG_VALUE == true)
      widget.autoLogin = true;

    if (!widget.autoLogin) {
      /* we make sure the login is a success */
      results = await Navigator.of(context).push(
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginOTPConfirmationPage(
                      username: customer.username, otp_code: mOtp),
              transitionsBuilder: (context, animation, secondaryAnimation,
                  child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin: begin, end: end);
                var curvedAnimation = CurvedAnimation(
                    parent: animation, curve: curve);
                return SlideTransition(
                    position: tween.animate(curvedAnimation), child: child);
              }
          ));
    } else {
      results['otp_valid'] = "valid";
    }

    String res = results['otp_valid'];
    if ("valid".compareTo(res) == 0) {
      // login ok
      // once we have the result we redirect
      String token = obj["data"]["payload"]["token"];
      CustomerUtils.persistTokenAndUserdata(token, json.encode(obj));

      // remove all login informations
      CustomerUtils.clearOtpLoginInfoFromSharedPreference(customer?.username);

      if (widget.fromOrderingProcess) {
        // pop
        Navigator.of(context).pop();
        StateContainer
            .of(context)
            .updateLoggingState(state: 1);
      } else {
        /* jump to home page. */
        StateContainer
            .of(context)
            .updateLoggingState(state: 1);
        Navigator.of(context).pushReplacement(
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomePage(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) {
                  var begin = Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end);
                  var curvedAnimation = CurvedAnimation(
                      parent: animation, curve: curve);
                  return SlideTransition(
                      position: tween.animate(curvedAnimation), child: child);
                }
            ));
      }
    } else {
      // login not ok , you have to redo
      // to re-log with your credentials once again
      mDialog("Login not ok, you have to redo again");
    }
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isConnecting = isLoading;
    });
  }

  void mToast(String message) {
    mDialog(message);
  }

  void mDialog(String message) {

    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
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


  Future<bool> _getIsOkWithTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOkWithTerms = false;
    try {
      // prove me it's not first time
      isOkWithTerms = prefs.getBool("_is_ok_with_terms");
    } catch(_){
      // is first time
      isOkWithTerms = false;
    }
    if (isOkWithTerms == null)
      isOkWithTerms = false;
    return isOkWithTerms;
  }


  void _askTerms() {

    showDialog(barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                          VectorsData.terms_and_conditions
                      )),
                  SizedBox(height: 10),
                  Text("${AppLocalizations.of(context).translate('accept_terms_and_conditions')}", textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions: <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('yes')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () async {
                  //
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("_is_ok_with_terms", true).then((value) {
                    // dismiss
                    Navigator.of(context).pop();
                  });
                },
              ),
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('see')}", style: TextStyle(color: KColors.mBlue)),
                onPressed: () {
                  _seeTermsAndConditions();
                },
              ),
            ]
        );
      },
    );
  }

  void _seeTermsAndConditions() {
    _launchURL(ServerRoutes.CGU_PAGE);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void accountNoExist(String login) {
    _showDialog(
        icon: Icon(Icons.pan_tool, color: Colors.red),
        message: "${AppLocalizations.of(context).translate('sorry')}, ${_loginFieldController.text} ${AppLocalizations.of(context).translate('account_no_exists')} ?",
        isYesOrNo: true,
        actionIfYes: () => _moveToRegisterPage(login)
    );
  }

  @override
  void loginPasswordError() {
    _showDialog(
      icon: Icon(Icons.error, color: Colors.red),
      message: "${AppLocalizations.of(context).translate('password_wrong')}",
      isYesOrNo: false,
    );
  }

  @override
  void networkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  @override
  void loginTimeOut() {
    mToast("${AppLocalizations.of(context).translate('login_time_out')}");
  }

  @override
  void systemError() {
    mToast("${AppLocalizations.of(context).translate('system_error')}");
  }


}
