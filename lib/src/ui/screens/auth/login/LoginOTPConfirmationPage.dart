import 'dart:async';

import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../StateContainer.dart';


class LoginOTPConfirmationPage extends StatefulWidget {

  static var routeName = "/LoginOTPConfirmationPage";

  CustomerModel customer;

  RecoverPasswordPresenter presenter;

  bool is_a_process;

  LoginOTPConfirmationPage({Key key, this.presenter, this.is_a_process = false}) : super(key: key);

  @override
  _LoginOTPConfirmationPageState createState() => _LoginOTPConfirmationPageState();
}

class _LoginOTPConfirmationPageState extends State<LoginOTPConfirmationPage> {

  TextEditingController _otpFieldController = new TextEditingController();

  int CODE_EXPIRATION_LAPSE = 10*60; /* minutes *  seconds */

  int timeDiff = 0;

  String _requestId;

  int _inputCount = 4;

  String pwd = "";

  @override
  void initState() {
    super.initState();

    CustomerUtils.getCustomer().then((customer) {
      if (customer != null) {
        xrint("LoginOTPConfirmationPage : "+customer.toJson().toString());
        setState(() {
          if (customer.phone_number == null) {
            if (customer.email == null) {
              // check if logged in, if yes, log out...
              xrint("customer email is no null");
              CustomerUtils.clearCustomerInformations().whenComplete(() {
                StateContainer.of(context).updateLoggingState(state: 0);
                StateContainer.of(context).updateBalance(balance: 0);
                StateContainer.of(context).updateKabaPoints(kabaPoints: "");
                StateContainer.of(context).updateUnreadMessage(
                    hasUnreadMessage: false);
                StateContainer.of(context).updateTabPosition(tabPosition: 0);
                Navigator.pushNamedAndRemoveUntil(
                    context, SplashPage.routeName, (r) => false);
              });
            } else {
              // _loginFieldController.text = customer.email;
            }
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loginFieldHint = "${AppLocalizations.of(context).translate('phone_number_hint')}";
    // recoverModeHints = ["${AppLocalizations.of(context).translate('recover_password_hint')}",/*"Insert your E-mail address"*/];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: KColors.primaryColor,
          title: Text("Verify", style:TextStyle(color:KColors.white)),
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.white), onPressed: (){Navigator.pop(context);}),
        ),
        body: Container(
            padding: EdgeInsets.only(bottom: 30),
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                    color: KColors.primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width/5
                ),
                Column(mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Card(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child:
                          Container(
                            padding: EdgeInsets.only(left: 20, right:20, top:20, bottom: 20),
                            child: Column(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(ImageAssets.smartphoneUnlock,height: 90, width: 90, alignment: Alignment.center,),
                                  SizedBox(height: 20),
                                  Text("Identity verification", style: TextStyle(fontSize: 24)),
                                  SizedBox(height:20),
                                  Text("Check your email/phone. we have sent you the code at ..8725.", textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 14, color: Colors.grey)),
                                  SizedBox(height:20),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[]
                                        ..addAll(
                                            List<Widget>.generate(_inputCount, (int index) {
                                              return Container(
                                                  margin: EdgeInsets.only(right: (index!=_inputCount-1?10:0)),
                                                  decoration: new BoxDecoration(
                                                    border: new Border(bottom: BorderSide(color:Colors.black, width: 2)),
                                                  ),
                                                  child: SizedBox(width: 40, height:40,child:Center(child:
                                                  Text(pwd.trim().length > index ? /*pwd[index]*/ "${pwd.substring(index,index+1)}" : "",
                                                      // TextField(decoration: new InputDecoration.collapsed(hintText: "*"),
                                                      style: TextStyle(fontSize: 30,color: Colors.black)))));
                                            })
                                        )
                                  ),/* rows for password */
                                  SizedBox(height:20),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Row(mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(child: Icon(FontAwesome.clock_o, color: Colors.grey), height: 20, width: 20),
                                              SizedBox(width: 30),
                                              Text("09 Seconds", style: TextStyle(color: Colors.grey, fontSize: 12))
                                            ]
                                        ),
                                      )
                                  ),
                                ]),
                          )
                      ),
                    ),
                    Container(child: Column(
                      children: [
                        SizedBox(width: 280,child:
                        Table(
                          children: <TableRow>[
                            TableRow(
                                children: <TableCell>[
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("1"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("1");}), padding: EdgeInsets.all(5))),
                                  TableCell(child: RawMaterialButton(child:Text("2"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("2");})),
                                  TableCell(child: RawMaterialButton(child:Text("3"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("3");})),
                                ],
                            ),
                            TableRow(
                                children: <TableCell>[
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("4"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("4");}), padding: EdgeInsets.all(5))),
                                  TableCell(child: RawMaterialButton(child:Text("5"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("5");})),
                                  TableCell(child: RawMaterialButton(child:Text("6"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("6");})),
                                ]
                            ),

                            TableRow(
                                children: <TableCell>[
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("7"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("7");}), padding: EdgeInsets.all(5))),
                                  TableCell(child: RawMaterialButton(child:Text("8"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("8");})),
                                  TableCell(child: RawMaterialButton(child:Text("9"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("9");})),
                                ]
                            ),
                            TableRow(
                                children: <TableCell>[
                                  TableCell(child:Text("")),
                                  TableCell(child: RawMaterialButton(child:Text("0"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("0");})),
                                  TableCell(child: RawMaterialButton(child:Text("X"), padding: EdgeInsets.all(16.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_removeChar();})),
                                ]
                            ),
                          ],
                        )),
                      ],
                    ))
                  ],
                ),
              ],
            )
        ));
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
        StateContainer.of(context).updateKabaPoints(kabaPoints: "");
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

  void _removeChar() {
    setState(() {
      pwd = pwd.substring(0, pwd.length-1);
    });
  }

  void _passwordAppendChar(String char) {

    xrint("appending -> ${char}");

    if (pwd.length <= 4) {
      setState(() {
        pwd = "${pwd}${char}";
      });
    }

    xrint("after appending -> ${pwd}");

    if (pwd.length != 4)
      return;

    validateCodeAndConfirm(pwd).then((isOtpValid) {
      if (isOtpValid) {
        // move to home page
      } else {
        /* reduce login chances down and ask again password */
      }
    });
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

  void mToast(String message) {
    mTDialog(message);
  }

  void mTDialog(String message) {

    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showTDialog(
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
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              OutlineButton(
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

  Future<bool> validateCodeAndConfirm(String pwd) async {
    String otp = await CustomerUtils.getLoginOtpCode();
    return pwd.compareTo(otp) == 0;
  }

}
