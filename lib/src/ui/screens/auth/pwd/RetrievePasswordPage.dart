import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/login/ForgottenPasswordOTP.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginOTPnewPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RetrievePasswordPage extends StatefulWidget {
  static var routeName = "/RetrievePasswordPage";

  final int type;
  final String? login;

  const RetrievePasswordPage({Key? key, this.type = 0, this.login}) : super(key: key);

  @override
  _RetrievePasswordPageState createState() => _RetrievePasswordPageState();
}

class _RetrievePasswordPageState extends State<RetrievePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  String errorMessage = "";

  List<String>? retrievePasswordTitle;

  @override
  void initState() {
    super.initState();
    retrievePasswordTitle = ["", "", "", ""];
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

  void _submitCode() {
    String enteredPassword = passwordController.text;

    if (enteredPassword.isEmpty) {
      setState(() => errorMessage =
          AppLocalizations.of(context)!.translate('enter_password_error'));
      return;
    }

    if (enteredPassword.length != 4) {
      setState(() => errorMessage =
          AppLocalizations.of(context)!.translate('password_min_error'));
      return;
    }

    Navigator.of(context).pop({'code': enteredPassword, 'type': widget.type});
  }

  void _jumpToOTPPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage(
          presenter: RecoverPasswordPresenter(RecoverPasswordView()),
          login: widget.login,
        ),
      ),
    );
  }

  void showReceiveCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${AppLocalizations.of(context)!.translate('confirmation_title')}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "${AppLocalizations.of(context)!.translate('otp_info')}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _jumpToOTPPage,
                    child: Text(
                      "${AppLocalizations.of(context)!.translate('proceed')}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          Utils.capitalize("${AppLocalizations.of(context)!.translate('input_password')}"),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.type != 3 ? FontAwesomeIcons.rightFromBracket : Icons.shopping_bag,
                        color: KColors.primaryColor,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.type != 3
                            ? "${AppLocalizations.of(context)!.translate('login')}"
                            : "${AppLocalizations.of(context)!.translate('validate_order')}",
                        style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "${AppLocalizations.of(context)!.translate('enter_password')}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "${AppLocalizations.of(context)!.translate('password')}",
                      prefixIcon: const Icon(Icons.lock_outline, color: KColors.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: KColors.primaryColor,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 30),
                  // Submit Button
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
                        widget.type != 3
                            ? "${AppLocalizations.of(context)!.translate('login_button')}"
                            : "${AppLocalizations.of(context)!.translate('validate_button')}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Forgot Password
                  TextButton(
                    onPressed: () => showReceiveCodeBottomSheet(context),
                    child: Text(
                      "${AppLocalizations.of(context)!.translate('forgot_password')}",
                      style: const TextStyle(color: KColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              "assets/images/background/Patternlogin.png",
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
