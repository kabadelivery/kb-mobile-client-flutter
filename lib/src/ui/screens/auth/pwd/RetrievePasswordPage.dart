import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/login/ForgottenPasswordOTP.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginOTPnewPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/services.dart';
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
  final FocusNode passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
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
      AppLocalizations.of(context)!.translate('enter_password'),
      AppLocalizations.of(context)!.translate('setup_password'),
      AppLocalizations.of(context)!.translate('confirm_password'),
      AppLocalizations.of(context)!.translate('confirm_password_launch_order'),
    ];
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    final enteredPassword = passwordController.text.trim();

    if (enteredPassword.isEmpty) {
      setState(() {
        errorMessage =
            AppLocalizations.of(context)!.translate('enter_password_error');
      });
      return;
    }

    if (enteredPassword.length != 4) {
      setState(() {
        errorMessage =
            AppLocalizations.of(context)!.translate('password_min_error');
      });
      return;
    }

    setState(() {
      errorMessage = "";
      _isSubmitting = true;
    });

    try {
      if (!mounted) return;
      Navigator.of(context).pop({
        'code': enteredPassword,
        'type': widget.type,
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  void _jumpToOTPPage(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();

    Future.microtask(() {
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecoverPasswordPage(
            login: widget.login,
            presenter: RecoverPasswordPresenter(RecoverPasswordView()),
          ),
        ),
      );
    });
  }

  void showReceiveCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
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
                    onPressed: () => _jumpToOTPPage(sheetContext),
                    child: Text(
                      AppLocalizations.of(context)!.translate('proceed'),
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
    debugPrint("login ${widget.login}");
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 50.0,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.type != 3
                            ? FontAwesomeIcons.rightFromBracket
                            : Icons.shopping_bag,
                        color: KColors.primaryColor,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.type != 3
                            ? AppLocalizations.of(context)!.translate('login')
                            : AppLocalizations.of(context)!.translate('validate_order'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context)!.translate('enter_password'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitCode(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate('password'),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: KColors.primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: KColors.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

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
                            ? AppLocalizations.of(context)!.translate('login_button')
                            : AppLocalizations.of(context)!.translate('validate_button'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => showReceiveCodeBottomSheet(context),
                    child: Text(
                      AppLocalizations.of(context)!.translate('forgot_password'),
                      style: const TextStyle(color: KColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ExcludeSemantics(
                child: Image.asset(
                  "assets/images/background/Patternlogin.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
