import 'dart:async';
import 'dart:convert';

import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../../../StateContainer.dart';
import '../../../../utils/_static_data/AppConfig.dart';


class LoginOTPConfirmationPage extends StatefulWidget {

  static var routeName = "/LoginOTPConfirmationPage";

  CustomerModel? customer;

  RecoverPasswordPresenter? presenter;

  String? username;

  String? login ;

  String? otp_code;

  String? request_id;


  LoginOTPConfirmationPage({Key? key, this.username, this.otp_code , required this.login,required this.request_id}) : super(key: key);

  @override
  _LoginOTPConfirmationPageState createState() => _LoginOTPConfirmationPageState();
}

class _LoginOTPConfirmationPageState extends State<LoginOTPConfirmationPage> {

  TextEditingController _otpFieldController = new TextEditingController();

  bool _showReceiveOption = false;

  String errorMessage = "";

  String? _selectedOption = "whatsapp";
  int _remainingSeconds = 90; // 90 seconds timer
  Timer? _timer;
  int? timeDiff = 0;
  bool otp_loading=false;
  String? _requestId;

  int? _inputCount = 4;

  String? pwd = "";

  int tryCount = 0;

  String? username;

  DateTime? lastCodeSentDatetime = DateTime.now();

  bool? loadingToGoOut = false;

  bool? showErrorMessage = false;

  bool? errorAnimated = false;

  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _startTimer();
    // trigger counter ,
    /* mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(lastCodeSentDatetime!.add(Duration(seconds: CODE_EXPIRATION_LAPSE)))) {
        xrint("time has ellapsed;");
        timer.cancel();
        Navigator.of(context).pop({'otp_valid': "no"});
      } else {
        /* update text;;; if codeIsSent */
        setState(() {
          /* convert into minutes, and show it */
          Duration duration = lastCodeSentDatetime!.add(Duration(seconds: CODE_EXPIRATION_LAPSE)).difference(DateTime.now());
          timeDiff = duration.inSeconds;
        });
      }
    });*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    /*try {
      mainTimer!.cancel();
    } catch(_) {
      xrint(_);
    }*/
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _showReceiveOption = true);
      }
    });
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
          if (_controllers.every((c) => c.text.isNotEmpty)) {
            _timer?.cancel(); // ✅ Stop timer once OTP is complete
          }
        },
      ),
    );
  }

  showReceiveCodeBottomSheet(BuildContextcontext) {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      expand: false,
      context: context,
      builder: (context) => Container(
          width: 335,
          height: 155,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Container(
                  width:double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Text("${AppLocalizations.of(context)!.translate('contact_support_to_get_otp')}",style: TextStyle(color: Colors.white,fontSize: 14))),
              InkWell(
                onTap: ()async{
                  var url = "tel:${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.translate('phone_call')}",
                            style: TextStyle(
                                fontSize: 14,
                                color: KColors.new_black,
                                fontWeight: FontWeight.w500)),
                        Icon(Icons.call, size: 20, color: KColors.primaryColor)
                      ]),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: KColors.new_gray,
                  height: 1),
              InkWell(
                onTap: () async{
                  final link = WhatsAppUnilink(
                    phoneNumber: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}',
                    text: "${AppLocalizations.of(context)!.translate('i_want_otp_code')}",
                  );
                  await launch('$link');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.translate('whatsapp')}",
                            style: TextStyle(
                                fontSize: 14,
                                color: KColors.new_black,
                                fontWeight: FontWeight.w500)),
                        // Icon(Icons.call, size: 20, color: KColors.primaryColor)
                        Container(
                            width: 20,
                            height: 20,
                            child: Image.asset(ImageAssets.whatsapp)),
                      ]),
                ),
              ),
            ],
          )),
    );
  }

  Future<void> _submitCode() async {
    final enteredCode = _controllers.map((c) => c.text).join();

    // 1️⃣ Validation locale basique
    if (enteredCode.length != 4 || !Utils.isCode(enteredCode)) {
      setState(() => errorMessage = "Veuillez entrer un code OTP valide.");
      return;
    }

    setState(() {
      errorMessage = "";
      otp_loading = true;
    });

    final client = ClientPersonalApiProvider();

    try {
      // 2️⃣ Tentative de validation serveur (SOURCE DE VÉRITÉ)
      final response = await client.checkRequestCodeAction(
        enteredCode,
        widget.request_id!,
      );

      final data = jsonDecode(response);

      if (data['error'] == 0) {
        // ✅ Validé par le backend
        _goOutValid();
        return;
      }

      // ❌ Le serveur a répondu → REFUS
      setState(() {
        otp_loading = false;
        errorMessage = data['message'] ?? "Code OTP invalide.";
      });

    } catch (e) {
      // 3️⃣ FALLBACK CLIENT (serveur injoignable)
      debugPrint("⚠️ Backend unreachable, fallback client validation");

      if (enteredCode == widget.otp_code) {
        // ⚠️ ACCEPTATION TEMPORAIRE
        _goOutValid(fallback: true);
      } else {
        setState(() {
          otp_loading = false;
          errorMessage = "Code incorrect ou connexion indisponible.";
        });
      }
    }
  }
  void _goOutValid({bool fallback = false}) {
    if (!mounted) return;

    setState(() {
      otp_loading = false;
      loadingToGoOut = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.of(context).pop({
          'otp_valid': "valid",
          'fallback': fallback, // 🔍 info utile pour debug/log
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
        body:     Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(FontAwesomeIcons.rightFromBracket,
                        color: KColors.primaryColor, size: 25),
                    SizedBox(width: 10),
                    Text("Connexion",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "Entrez le code de vérification",
                  // "${AppLocalizations.of(context)!.translate('verif_c_t')}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                  List.generate(4, (index) => _buildOtpField(index)),
                ),
                const SizedBox(height: 20),

                // 🔹 Timer display
                if (!_showReceiveOption)
                  Text(
                    "Expiration du code dans $_remainingSeconds s",
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 30),

                if (errorMessage.isNotEmpty)
                  Text(errorMessage,
                      style:
                      const TextStyle(color: Colors.red, fontSize: 12)),

                const SizedBox(height: 30),

                // ✅ Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primaryColor,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitCode,
                    child: Text("${AppLocalizations.of(context)!.translate('validate')}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
    SizedBox(height: 15,),
                otp_loading?CircularProgressIndicator(color: KColors.primaryColor,):
    Opacity(
    opacity: _remainingSeconds == 0 ? 1.0 : 0.5,
    child: Column(
      children: [
        OutlinedButton(
        onPressed: _remainingSeconds == 0
        ? () async {
        debugPrint("resend code pressed; ${widget.username}");
        ClientPersonalApiProvider client = ClientPersonalApiProvider();
        setState(() {
        otp_loading = true;
        });
        var response =
        await client.recoverPasswordSendingCodeAction(widget.username!);

        setState(() {
        var data = jsonDecode(response);
        if (data['error'] == 0) {
        pwd = "";
        _remainingSeconds = 90;
        _showReceiveOption = false;
        widget.otp_code = data['data']['code'].toString();
        widget.request_id = data['data']['request_id'].toString();
        otp_loading = false;
        _startTimer();
        mToast("Le code a été renvoyé avec succès.");
        } else {
        mToast("Erreur lors de l'envoi du code. Veuillez réessayer.");
        }
        });
        }
            : null, // désactive automatiquement le bouton
        style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: KColors.primaryColor, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        ),
        ),
        child:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
            "Recevoir le code par WhatsApp",
            style: TextStyle(
            color: KColors.primaryColor,
            fontWeight: FontWeight.w500,
            ),
            ),
            SizedBox(width: 10),
            Icon(FontAwesomeIcons.whatsapp,color: KColors.primaryColor,)
          ],
        ),
        ),
        SizedBox(height: 10),
        _remainingSeconds==0?TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.all(8.0),
              backgroundColor: KColors.primaryColor.withOpacity(.1)
          ),
          onPressed:(){
            if(_remainingSeconds == 0){
              showReceiveCodeBottomSheet(context);
            }
          },
          child: Text(
            AppLocalizations.of(context)!.translate('contact_support_to_get_otp'),
            style: const TextStyle(color: KColors.primaryColor),
          ),
        ):SizedBox(),
      ],
    ),
    ),

    ],
            ),
            Image.asset("assets/images/background/Patternlogin.png",
                fit: BoxFit.cover, width: MediaQuery.of(context).size.width),
          ],
        ),

      /* Stack(
              children: [
               /* Container(
                    color: KColors.primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width/5
                ),*/
                /*Column(mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Card(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child:
                         /* Container(
                            padding: EdgeInsets.only(left: 20, right:20, top:20, bottom: 20),
                            child: Column(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(ImageAssets.smartphoneUnlock,height: 50, width: 50, alignment: Alignment.center,),
                                  SizedBox(height: 20),
                                  Text("${AppLocalizations.of(context)!.translate('identity_verify_title')}", style: TextStyle(fontSize: 20)),
                                  SizedBox(height:20),
                                  Text("${Utils.isPhoneNumber_TGO(widget.username!)? AppLocalizations.of(context)!.translate('identity_check_pn') : AppLocalizations.of(context)!.translate('identity_check_email')} "+( Utils.isPhoneNumber_TGO(widget.username!)? "XXXX${widget.username!.substring(4)}" : "${widget.username!.substring(0,4)}****${widget.username!.substring(widget.username!.lastIndexOf("@")-1)}"), textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 13, color: Colors.grey)),
                                  SizedBox(height:10),
                                  /* code error */
                                  showErrorMessage! ?
                                  Container(
                                      child: Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(Icons.stop_circle_outlined, color: KColors.primaryColor),
                                            SizedBox(width:8),
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.bounceOut,
                                              style: errorAnimated! ? TextStyle(
                                                fontSize: 16,
                                                color: KColors.primaryColor
                                              ) : TextStyle(
                                                  fontSize: 0,
                                                  color: Colors.orange
                                              ),
                                              child: Text(
                                                '${AppLocalizations.of(context)!.translate("verification_code_wrong")}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            // Text("${AppLocalizations.of(context)!.translate("verification_code_wrong")}")
                                          ]
                                      )
                                  )
                                      :
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[]
                                        ..addAll(
                                            List<Widget>.generate(_inputCount!, (int index) {
                                              return Container(
                                                  margin: EdgeInsets.only(right: (index!=_inputCount!-1?10:0)),
                                                  decoration: new BoxDecoration(
                                                    border: new Border(bottom: BorderSide(color:KColors.new_black, width: 2)),
                                                  ),
                                                  child: SizedBox(width: 30, height:30,child:Center(child:
                                                  Text(pwd!.trim().length > index ? /*pwd[index]*/ "${pwd!.substring(index,index+1)}" : "",
                                                      // TextField(decoration: new InputDecoration.collapsed(hintText: "*"),
                                                      style: TextStyle(fontSize: 30,color: KColors.new_black)))));
                                            })
                                        )
                                  ),/* rows for password */
                                  SizedBox(height:20),
                                  loadingToGoOut! ?
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
                                              SizedBox(child: Icon(FontAwesomeIcons.clock, color: Colors.grey), height: 20, width: 20),
                                              SizedBox(width: 30),
                                              Text("${timeDiff} ${AppLocalizations.of(context)!.translate('seconds')}", style: TextStyle(color: Colors.grey, fontSize: 12))
                                            ]
                                        ),
                                      )
                                  ),
                                ]),
                          )*/
                      ),
                    ),
                    Container(child:

                  /*  Column(
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
                        )

                        ),
                      ],
                    )*/
                    )
                  ],
                ),*/



              ],
            )*/



    );
  }




  void _removeChar() {
    setState(() {
      pwd = pwd!.substring(0, pwd!.length-1);
    });
  }

  void _passwordAppendChar(String char) {

    if (showErrorMessage!)
      return;

    xrint("appending -> ${char}");

    if (pwd!.length <= 4) {
      setState(() {
        pwd = "${pwd}${char}";
      });
    }

    xrint("after appending -> ${pwd}");

    if (pwd!.length != 4)
      return;


    validateCodeAndConfirm(pwd!).then((isOtpValid) {

      if (isOtpValid) {
        // move to home page,,, with pop
        setState(() {
          loadingToGoOut = true;
        });
        Future.delayed(Duration(seconds: 2), (){
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

  Future<bool> validateCodeAndConfirm(String pwd) async {
    String otp = widget.otp_code!;
    return pwd.compareTo(otp) == 0;
  }

}


