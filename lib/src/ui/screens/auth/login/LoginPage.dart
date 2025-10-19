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
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


const String DEMO_ACCOUNT_USERNAME = "90000000";

class LoginPage extends StatefulWidget {

  static var routeName = "/LoginPage";

  LoginPresenter? presenter;

  bool? autoLogin = false;

  String? phone_number, password;

  String? version;

  bool? fromOrderingProcess;

  LoginPage({Key? key, this.title, this.presenter, this.phone_number, this.password, this.autoLogin = false, this.fromOrderingProcess = false}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginView {

  String hint = "";

  bool isConnecting = false;

  bool isPhoneSelected = true;

  TextEditingController _loginFieldController = new TextEditingController();

  bool _loading = false;

  String selectedCountryCode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hint = "${AppLocalizations.of(context)!.translate('login_phonenumber_hint')}";
  }

  @override
  void initState() {
    super.initState();
    this.widget.presenter!.loginView = this;

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
      _loginFieldController.text = widget.phone_number!;
      if ((Utils.isPhoneNumber_TGO(widget.phone_number!) || Utils.isEmailValid(widget.phone_number!)) )

        debugPrint("Mot de Passe is : "+widget!.password.toString());
      widget.presenter!.login(false/*bcs autologin*/, widget.phone_number!, widget.password!, widget.version??"");
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
            child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[ Padding(
                  padding: EdgeInsets.all(20) ,
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        SizedBox(height: 100),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.rightFromBracket, color: KColors.primaryColor, size:25),
                            SizedBox(width: 10),
                            Text("${AppLocalizations.of(context)!.translate('connexion')}", style:TextStyle(color:Colors.black, fontSize: 20 , fontWeight: FontWeight.w600 )),
                            SizedBox(width: 5),
                            //Text("${AppLocalizations.of(context)!.translate('name_app')}", style:TextStyle(color:KColors.primaryColor, fontSize: 23 , fontWeight: FontWeight.bold )),
                          ],
                        ),
                        SizedBox(height: 40),


                        Text(
                          AppLocalizations.of(context)!.translate('welcome_kaba'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: KColors.primaryColor,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                            margin: EdgeInsets.only(left:35, right: 35),
                            child:
                            Text(hint, textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                        SizedBox(height: 30),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 8 , vertical:8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 10)
                                )
                              ],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: KColors.primaryColor, width: 1.2),
                            ),
                            child:  Row(
                              children: [
                                // PHONE BUTTON
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isPhoneSelected = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12 ,horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: isPhoneSelected ? KColors.primaryColor : Colors.white,
                                        // border: Border.all(color: KColors.primaryColor, width: 1.5),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10) ,
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.phone_iphone,
                                            color: isPhoneSelected ? Colors.white : KColors.primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            AppLocalizations.of(context)!.translate('phone_number'),
                                            style: TextStyle(
                                              color: isPhoneSelected ? Colors.white : KColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // EMAIL BUTTON
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isPhoneSelected = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !isPhoneSelected ? KColors.primaryColor : Colors.white,
                                        //border: Border.all(color: KColors.primaryColor, width: 1.5),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10) ,
                                          bottomLeft: Radius.circular(10) ,
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            color: !isPhoneSelected ? Colors.white : KColors.primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Email",
                                            style: TextStyle(
                                              color: !isPhoneSelected ? Colors.white : KColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )

                        ),
                        SizedBox(height: 20),

                        if (isPhoneSelected) ...[
                          TextFormField(
                            controller: _loginFieldController,
                            onChanged: (_) {
                              setState(() {
                                _loading = false;
                              });
                            },
                            enabled: !isConnecting,
                            maxLength: TextField.noMaxLength,
                            decoration: InputDecoration(
                              // 👈 reduce field height
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // 👈 smaller padding
                                child: CountryCodePicker(
                                  onChanged: (code) {
                                    setState(() {
                                      selectedCountryCode = code.dialCode ?? '';
                                    });
                                    debugPrint("New country selected: ${code.dialCode}");
                                  },
                                  initialSelection: 'TG', // default to Togo
                                  favorite: const ['+228', 'TG'], // keep Togo as favorite
                                  showFlag: true,
                                  showDropDownButton: true,
                                  textStyle: const TextStyle(color: Colors.black, fontSize: 12), // 👈 smaller text
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              hintText: AppLocalizations.of(context)!.translate('enter_phone_number'),

                              hintStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: KColors.primaryColor),
                                borderRadius: BorderRadius.circular(20), // 👈 smaller radius
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: KColors.primaryColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: KColors.primaryColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 14), // 👈 smaller input text
                          ),

                          /* SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child:
                             TextField(controller: _loginFieldController, enabled: !isConnecting, maxLength: TextField.noMaxLength, keyboardType: TextInputType.text, decoration:
                            InputDecoration.collapsed(hintText: "${AppLocalizations.of(context)!.translate('identifier')}"), style: TextStyle(color:KColors.new_black)),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))

                            ) */
                        ] else ...[
                          TextFormField(
                            controller: _loginFieldController,
                            enabled:!isConnecting, maxLength: TextField.noMaxLength,
                            decoration: InputDecoration(

                              prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: AppLocalizations.of(context)!.translate('enter_email'),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        SizedBox(height: 20),
                        _loading?CircularProgressIndicator():
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onPressed: () {

                              _checklogin();
                            },
                            child: Text(
                              AppLocalizations.of(context)!.translate('continue_arrow'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),

                          ),
                        ),

                        SizedBox(height: 30),
                        /*  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                            children: <Widget>[
                              Text("${AppLocalizations.of(context)!.translate('connexion')}", style: TextStyle(fontSize: 14, color: Colors.white)),
                              isConnecting ?  Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15),
                                ],
                              )  : Container(),
                            ],
                          ), onPressed: () {
                            _launchConnexion();
                            }),
                          SizedBox(width:20),
                          MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:KColors.primaryYellowColor,child: Text("${AppLocalizations.of(context)!.translate('register')}", style: TextStyle(fontSize: 14, color: Colors.white)), onPressed: () {_moveToRegisterPage(null);}),
                        ]), */


                        //Text("${AppLocalizations.of(context)!.translate('name_app')}", style:TextStyle(color:KColors.primaryColor, fontSize: 23 , fontWeight: FontWeight.bold )),

                      ]
                  ),
                ),
                  SizedBox(height: 90),
                  Image.asset(
                    "assets/images/background/Patternlogin.png",
                    width: double.infinity,
                    height: 275,
                    fit: BoxFit.cover, // scales and crops to cover the width
                  ),
                ]
            ),
          ),
        ));
  }

  Future<void> _moveToRegisterPage(String? login) async {

    /*  Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage (presenter: RegisterPresenter()),
      ),
    );*/

    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            RegisterPage (presenter: RegisterPresenter(RegisterView()), login: login),
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
        _loginFieldController.text = selectedCountryCode+results['phone_number'];
      });
      showLoading(true);
      // launch request for retrieving the delivery prices and so on.
      if (results['autologin'] == true){
        widget.autoLogin = true;
      }
      widget.presenter!.login(false, results['phone_number'], results['password'], widget.version!);
    }
  }

  void _moveToRecoverPasswordPage() {

    Navigator.of(context).pushReplacement(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
//            RegisterPage (presenter: RegisterPresenter()),
        RecoverPasswordPage(presenter: RecoverPasswordPresenter(RecoverPasswordView())),
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



  Future _checklogin() async {
    setState(() {
      _loading = true;
    });
    String login = selectedCountryCode+_loginFieldController.text;

    // control login stuff
    /*  if (!(Utils.isEmailValid(login) || Utils.isPhoneNumber_TGO(login))) {
      /* login error */
      mToast("${AppLocalizations.of(context)!.translate('login_error')}");
      return;
    }*/

    /* // 1. get password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return RetrievePasswordPage(type: 0);
        }
    )); */

    // if (results != null && results.containsKey('code') && results.containsKey('type'))
    String _mCode = '0000';
//      int type = results['type'];
    showLoading(true);


    /* check if it's important to send another sms according to the time lapsed after the last sending
      * 1. check last time sent message, if before 5 minutes, then dont send,
      * 2. otherwise send
      *  */
    CustomerUtils.getLastValidOtp(username: login).then((otp) {
      if ("no".compareTo(otp!) == 0) {

        if (login.compareTo(DEMO_ACCOUNT_USERNAME) == 0 ) {
          // widget.autoLogin = true;
          this.widget.presenter!.login(false, login, _mCode, widget.version!);
        } else
          this.widget.presenter!.login(true, login, _mCode, widget.version!);

      } else {
        this.widget.presenter!.login(false, login, _mCode, widget.version!);
      }
    });


  }

  Future _launchConnexion() async {

    String login = selectedCountryCode+_loginFieldController.text;

    // control login stuff
    /* if (!(Utils.isEmailValid(login) || Utils.isPhoneNumber_TGO(login))) {
      /* login error */
      mToast("${AppLocalizations.of(context)!.translate('login_error')}");
      return;
    }*/

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
          if ("no".compareTo(otp!) == 0) {

            if (login.compareTo(DEMO_ACCOUNT_USERNAME) == 0 || kDebugMode==true) {
              widget.autoLogin = true;
              this.widget.presenter!.login(false, login, _mCode, widget.version!);
            } else
              this.widget.presenter!.login(true, login, _mCode, widget.version!);

          } else {
            this.widget.presenter!.login(false, login, _mCode, widget.version!);
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

    String? otp = null;
    if (!widget.autoLogin!) {
      /* retrieve the otp and save it for later use */
      try {
        if (obj["login_code"] != null)
          otp = "${obj["login_code"]}";
      } catch (_) {
        otp = null;
      }
      /* save it to the shared preferences */
      if (otp != null) {
        CustomerUtils.saveOtpToSharedPreference(customer.username!,otp);
        await nextStepWithOtpConfirmationPage(customer, otp, obj);
      } else {
        CustomerUtils.getLastOtp(customer.username!).then((mOtp) async {
          // this is the otp
          if ("no".compareTo(mOtp!) == 0) {
            // login_failure
            showLoading(false);
          } else {
            /* if you are coming from another process like already making an order, then just pop */
            /* token must be saved by now. */
            await nextStepWithOtpConfirmationPage(customer, mOtp!, obj);
          }
        });
      }
    } else {
      // go directly
      await nextStepWithOtpConfirmationPage(customer, "", obj);
    }
    StateContainer.of(context).myBillingArray = null;
  }

  Future<void> nextStepWithOtpConfirmationPage(CustomerModel customer, String mOtp, dynamic obj) async {


    /* if you are coming from another process like already making an order, then just pop */
    /* token must be saved by now. */
    showLoading(false);

    Map results = Map();

    if ("${customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) == 0 || kDebugMode==true)
      widget.autoLogin = true;

    if (!widget.autoLogin!) {
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
      CustomerUtils.clearOtpLoginInfoFromSharedPreference(customer.username!);

      if (widget.fromOrderingProcess!) {
        // pop
        Navigator.of(context).pop();
        StateContainer
            .of(context)
            .updateLoggingState(state: 1);
        StateContainer.of(context).customer = customer;
      } else {
        /* jump to home page. */
        StateContainer
            .of(context)
            .updateLoggingState(state: 1);
        StateContainer.of(context).customer = customer;
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
      {String? svgIcons, Icon? icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function? actionIfYes}) {
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
                  actionIfYes!();
                },
              ),
            ] : <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
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
      isOkWithTerms = prefs.getBool("_is_ok_with_terms")!;
    } catch(_){
      // is first time
      isOkWithTerms = false;
    }
    if (isOkWithTerms == null)
      isOkWithTerms = false;
    return isOkWithTerms;
  }


  void _askTerms() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône document dans carré blanc
                Container(
                    height: 80,
                    width: 80,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: KColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.description_outlined,
                          color: KColors.primaryColor,
                          size: 40,
                        ),
                      ),
                    )
                ),

                const SizedBox(height: 20),

                // Texte principal avec "KABA" coloré
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate(
                            'accept_terms_and_conditions') + " ",
                      ),
                      TextSpan(
                        text: "KABA",
                        style: TextStyle(
                          color: KColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " ?",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton principal "OUI"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color(0xFFD13456),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('yes'),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      prefs.setBool("_is_ok_with_terms", true).then((value) {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Bouton secondaire "CONSULTER"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(Icons.visibility, color: KColors.primaryColor),
                    label: Text(
                      AppLocalizations.of(context)!.translate('see'),
                      style: TextStyle(
                          color: KColors.primaryColor, fontSize: 16),
                    ),
                    onPressed: () {
                      _seeTermsAndConditions();
                    },
                  ),
                ),
              ],
            ),
          ),
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
    /* _showDialog(
        icon: Icon(Icons.pan_tool, color: Colors.red),
        message: "${AppLocalizations.of(context)!.translate('sorry')}, ${_loginFieldController.text} ${AppLocalizations.of(context)!.translate('account_no_exists')} ?",
        isYesOrNo: true,
        actionIfYes: () => _moveToRegisterPage(login)
    ); */
    _moveToRegisterPage(login) ;
  }

  @override
  void loginPasswordError() {
    /* _showDialog(
      icon: Icon(Icons.error, color: Colors.red),
      message: "${AppLocalizations.of(context)!.translate('password_wrong')}",
      isYesOrNo: false,
    ); */
    _launchConnexion();
  }

  @override
  void networkError() {
    mToast("${AppLocalizations.of(context)!.translate('network_error')}");
  }

  @override
  void loginTimeOut() {
    mToast("${AppLocalizations.of(context)!.translate('login_time_out')}");
  }

  @override
  void systemError() {
    mToast("${AppLocalizations.of(context)!.translate('system_error')}");
  }


}
