import 'dart:async';
import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/login/ForgottenPasswordOTP.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginOTPnewPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../../../utils/_static_data/ImageAssets.dart';

class VerificationPage extends StatefulWidget {
  static var routeName = "/VerificationPage";
  final int type;

  const VerificationPage({Key? key, this.type = 0}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _obscurePassword = true;
  String errorMessage = "";
  bool _showReceiveOption = false; // 🔹 show button after timer ends
  int _remainingSeconds = 90; // 90 seconds timer
  Timer? _timer;

  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  List<String>? retrievePasswordTitle;
  String? _selectedOption = "whatsapp"; // 🔹 Default selected option

  @override
  void initState() {
    super.initState();
    retrievePasswordTitle = ["", "", "", ""];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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

  void _submitCode() {
    String enteredPassword = _controllers.map((c) => c.text).join();

    if (enteredPassword.isEmpty) {
      setState(() => errorMessage =
          AppLocalizations.of(context)!.translate('enter_password_error'));
      return;
    }

    if (enteredPassword.length < 4) {
      setState(() => errorMessage =
          AppLocalizations.of(context)!.translate('password_min_error'));
      return;
    }

    _timer?.cancel();
    Navigator.of(context)
        .pop({'code': enteredPassword, 'type': widget.type});
  }


  void _jumpToOTPPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotenPasswordOTP()),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    retrievePasswordTitle = [
      "${AppLocalizations.of(context)!.translate('enter_password')}",
      "${AppLocalizations.of(context)!.translate('setup_password')}",
      "${AppLocalizations.of(context)!.translate('confirm_password')}",
      "${AppLocalizations.of(context)!.translate('confirm_password_launch_order')}"
    ];
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
            _timer?.cancel();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FontAwesomeIcons.rightFromBracket, color: KColors.primaryColor, size: 25),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.translate('login'),
                      style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.translate('enter_verification_code'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => _buildOtpField(index)),
                ),
                const SizedBox(height: 20),

                // 🔹 Timer display
                if (!_showReceiveOption)
                  Text(
                    "${AppLocalizations.of(context)!.translate('otp_expires_in')} $_remainingSeconds s",
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 30),

                if (errorMessage.isNotEmpty)
                  Text(errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),

                const SizedBox(height: 30),

                // ✅ Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitCode,
                    child: Text(
                      AppLocalizations.of(context)!.translate('validate_button'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                if (_showReceiveOption)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(8.0),
                      backgroundColor: KColors.primaryColor.withOpacity(.1)
                    ),
                    onPressed: () => showReceiveCodeBottomSheet(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate('contact_support_to_get_otp'),
                      style: const TextStyle(color: KColors.primaryColor),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {}, // Disabled until timer ends
                    child: Text(
                      AppLocalizations.of(context)!.translate('forgot_password'),
                      style: const TextStyle(color: Colors.black38),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Image.asset(
            "assets/images/background/Patternlogin.png",
            fit: BoxFit.cover,
            height: 290,
          ),
        ],
      )

    );
  }
}
