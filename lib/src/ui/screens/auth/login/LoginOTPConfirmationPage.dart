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

  String username;

  String otp_code;

  LoginOTPConfirmationPage({Key key, this.username, this.otp_code}) : super(key: key);

  @override
  _LoginOTPConfirmationPageState createState() => _LoginOTPConfirmationPageState();
}

class _LoginOTPConfirmationPageState extends State<LoginOTPConfirmationPage> {

  TextEditingController _otpFieldController = new TextEditingController();

  int CODE_EXPIRATION_LAPSE = 2*60; /* minutes *  seconds */

  int timeDiff = 0;

  String _requestId;

  int _inputCount = 4;

  String pwd = "";

  int tryCount = 0;

  String username;

  Timer mainTimer;

  DateTime lastCodeSentDatetime = DateTime.now();

  bool loadingToGoOut = false;

  bool showErrorMessage = false;

  bool errorAnimated = false;

  @override
  void initState() {
    super.initState();

    // trigger counter ,
    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(lastCodeSentDatetime.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {
        xrint("time has ellapsed;");
        timer.cancel();
        Navigator.of(context).pop({'otp_valid': "no"});
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

  @override
  void dispose() {
    // TODO: implement dispose
    try {
      mainTimer.cancel();
    } catch(_) {
      xrint(_);
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: KColors.primaryColor,
          title: Text("${AppLocalizations.of(context).translate('identity_verify_page')}", style:TextStyle(color:KColors.white)),
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
                                  Image.asset(ImageAssets.smartphoneUnlock,height: 50, width: 50, alignment: Alignment.center,),
                                  SizedBox(height: 20),
                                  Text("${AppLocalizations.of(context).translate('identity_verify_title')}", style: TextStyle(fontSize: 20)),
                                  SizedBox(height:20),
                                  Text("${Utils.isPhoneNumber_TGO(widget.username)? AppLocalizations.of(context).translate('identity_check_pn') : AppLocalizations.of(context).translate('identity_check_email')} "+( Utils.isPhoneNumber_TGO(widget.username)? "XXXX${widget.username.substring(4)}" : "${widget.username.substring(0,4)}****${widget.username.substring(widget.username.lastIndexOf("@")-1)}"), textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 13, color: Colors.grey)),
                                  SizedBox(height:10),
                                  /* code error */
                                  showErrorMessage ?
                                  Container(
                                      child: Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(Icons.stop_circle_outlined, color: KColors.primaryColor),
                                            SizedBox(width:8),
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.bounceOut,
                                              style: errorAnimated ? TextStyle(
                                                fontSize: 16,
                                                color: KColors.primaryColor
                                              ) : TextStyle(
                                                  fontSize: 0,
                                                  color: Colors.orange
                                              ),
                                              child: Text(
                                                '${AppLocalizations.of(context).translate("verification_code_wrong")}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            // Text("${AppLocalizations.of(context).translate("verification_code_wrong")}")
                                          ]
                                      )
                                  )
                                      :
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[]
                                        ..addAll(
                                            List<Widget>.generate(_inputCount, (int index) {
                                              return Container(
                                                  margin: EdgeInsets.only(right: (index!=_inputCount-1?10:0)),
                                                  decoration: new BoxDecoration(
                                                    border: new Border(bottom: BorderSide(color:KColors.new_black, width: 2)),
                                                  ),
                                                  child: SizedBox(width: 30, height:30,child:Center(child:
                                                  Text(pwd.trim().length > index ? /*pwd[index]*/ "${pwd.substring(index,index+1)}" : "",
                                                      // TextField(decoration: new InputDecoration.collapsed(hintText: "*"),
                                                      style: TextStyle(fontSize: 30,color: KColors.new_black)))));
                                            })
                                        )
                                  ),/* rows for password */
                                  SizedBox(height:20),
                                  loadingToGoOut ?
                                  Center(child: SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.new_black)), height: 15, width: 15))
                                      :
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child:  Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(child: Icon(FontAwesome.clock_o, color: Colors.grey), height: 20, width: 20),
                                              SizedBox(width: 30),
                                              Text("${timeDiff} ${AppLocalizations.of(context).translate('seconds')}", style: TextStyle(color: Colors.grey, fontSize: 12))
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
                                TableCell(child: Container(child: RawMaterialButton(child:Text("1"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("1");}), padding: EdgeInsets.only(bottom:5))),
                                TableCell(child: Container(child: RawMaterialButton(child:Text("2"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("2");}), padding: EdgeInsets.only(bottom:5))),
                                TableCell(child: Container(child: RawMaterialButton(child:Text("3"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("3");}), padding: EdgeInsets.only(bottom:5))),
                              ],
                            ),
                            TableRow(
                                children: <TableCell>[
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("4"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("4");}), padding: EdgeInsets.only(bottom:5))),
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("5"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("5");}), padding: EdgeInsets.only(bottom:5))),
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("6"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("6");}), padding: EdgeInsets.only(bottom:5))),
                                ]
                            ),

                            TableRow(
                                children: <TableCell>[
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("7"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("7");}), padding: EdgeInsets.only(bottom:5))),
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("8"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("8");}), padding: EdgeInsets.only(bottom:5))),
                                  TableCell(child: Container(child: RawMaterialButton(child:Text("9"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("9");}), padding: EdgeInsets.only(bottom:5))),
                                ]
                            ),
                            TableRow(
                                children: <TableCell>[
                                  TableCell(child:Text("")),
                                  TableCell(child: RawMaterialButton(child:Text("0"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_passwordAppendChar("0");})),
                                  TableCell(child: RawMaterialButton(child:Text("X"), padding: EdgeInsets.all(14.0), shape: CircleBorder(), fillColor:Colors.grey.shade50, onPressed: () {_removeChar();})),
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




  void _removeChar() {
    setState(() {
      pwd = pwd.substring(0, pwd.length-1);
    });
  }

  void _passwordAppendChar(String char) {

    if (showErrorMessage)
      return;

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
        // move to home page,,, with pop
        setState(() {
          loadingToGoOut = true;
        });
        Future.delayed(Duration(seconds: 3), (){
          Navigator.of(context).pop({'otp_valid':"valid"});
        });
      } else {
        tryCount++;

        Future.delayed(Duration(milliseconds: 700), () {
          // show error message and hide numbers
          setState(() {
            showErrorMessage = true;
          });

          // delay start of animation
          Future.delayed(Duration(milliseconds: 300), () {
            setState(() {
              this.errorAnimated = true;
            });
          });

          // stop error animation
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              showErrorMessage = false;
              this.errorAnimated = false;
            });
            /* reduce login chances down and ask again password */
            if (tryCount == 3) {
              // pop out
              Navigator.of(context).pop({'otp_valid': "no"});
            } else {
              setState(() {
                pwd = "";
              });
            }
          });
        });
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
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
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
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
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

  Future<bool> validateCodeAndConfirm(String pwd) async {
    String otp = widget.otp_code;
    return pwd.compareTo(otp) == 0;
  }

}
