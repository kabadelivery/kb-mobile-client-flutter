import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../StateContainer.dart';
import '../../../../contracts/login_contract.dart';
import '../login/LoginOTPnewPage.dart';
import '../login/LoginPage.dart';
class RecoverPasswordPage extends StatefulWidget {
  static var routeName = "/RecoverPasswordPage";

  CustomerModel? customer;
  RecoverPasswordPresenter? presenter;
  bool? is_a_process;
  String? login;

  RecoverPasswordPage({
    Key? key,
    this.presenter,
    this.is_a_process = false,
    this.login,
  }) : super(key: key);

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage>
    implements RecoverPasswordView {
  String? _login;
  String? _requestId;
  String? _pendingPassword; // store password until OTP is verified

  bool _isLoadingLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.presenter!.recoverPasswordView = this;

    // Load login asynchronously
    CustomerUtils.getCustomer().then((customer) {
      setState(() {
        _login = customer?.phone_number ?? customer?.email ?? widget.login;
        _isLoadingLogin = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLogin) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('recover_password')}"),
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Utils.capitalize(
              "${AppLocalizations.of(context)!.translate('recover_password')}"),
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
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
              const Text(
                "Entrez le code de vérification",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 30),
              Text(
                "Réinitialisez votre mot de passe KABA ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
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
              ),
              SizedBox(height: 20),

              // Confirm Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: "Confirmez votre mot de passe",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Validate Button
              Container(
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _handleValidatePassword,
                  child: Text(
                    "Valider",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // Validate password and send OTP
  // -----------------------------
  Future<void> _handleValidatePassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final login = _login ?? "";

    if (password.isEmpty || confirm.isEmpty) {
      mDialog("${AppLocalizations.of(context)!.translate('fill_all_fields')}");
      return;
    }

    if(password.length != 4 || confirm.length != 4){
      //AppLocalizations.of(context)!.translate('password_min_error'));
      mDialog("${AppLocalizations.of(context)!.translate('password_min_error')}");
      return ;
    }

    if (password != confirm) {
      mDialog("${AppLocalizations.of(context)!.translate('passwords_not_match')}");
      return;
    }

    if (login.isEmpty) {
      mDialog("${AppLocalizations.of(context)!.translate('invalid_login')}");
      return;
    }

    // Store password temporarily until OTP is verified
    _pendingPassword = password;

    // Send OTP

    try {
      await widget.presenter!.sendVerificationCode(login);

      if ((_requestId ?? "").isEmpty) {
        // request id wasn't set — show error
        mDialog("${AppLocalizations.of(context)!.translate('no_otp_received')}");
        return;
      }
      // Navigate to OTP page
      var result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationPage(type: 0),
        ),
      );

      if (result != null && result['code'] != null) {
        _checkOtp(result['code']);
      } else {
        mDialog(
            "${AppLocalizations.of(context)!.translate('no_otp_received')}");
      }
    } catch (e) {
      // Presenter or network error should be surfaced here or via presenter's callbacks
      mDialog("${AppLocalizations.of(context)!.translate('no_otp_received')}");
    }
    finally {
      setState(() {

      });

    }


  }

  // -----------------------------
  // Check OTP only
  // -----------------------------
  void _checkOtp(String otp) {
    if (!Utils.isCode(otp)) {
      mDialog("${AppLocalizations.of(context)!.translate('invalid_otp_code')}");
      return;
    }

    // ensure request id exists
    if ((_requestId ?? "").isEmpty) {
      mDialog("${AppLocalizations.of(context)!.translate('no_otp_received')}");
      return;
    }

    widget.presenter!.checkVerificationCode(otp, _requestId!);
  }

// -----------------------------
// RecoverPasswordView callbacks
// -----------------------------
  @override
  @override
  void codeIsOk(bool isOk) async {
    if (!isOk) {
      mDialog("${AppLocalizations.of(context)!.translate('incorrect_otp_code')}");
      return;
    }

    final password = _pendingPassword;
    if (password == null || password.isEmpty) {
      mDialog("${AppLocalizations.of(context)!.translate('empty_password')}");
      return;
    }

    // show loading
    //setState(() { _isUpdatingPassword = true; });

    try {
      // Make sure presenter.updatePassword uses correct isWorking logic and always resets it.
      await widget.presenter!.updatePassword(_login!, password, _requestId ?? '');

      // On success the presenter should call recoverSuccess -> handle there, or rely on this code
      _pendingPassword = null;
      mToast("${AppLocalizations.of(context)!.translate('password_updated_success')}");

      if (!widget.is_a_process!) {
        await CustomerUtils.clearCustomerInformations();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              presenter: LoginPresenter(LoginView()),
              phone_number: _login!,
              password: password,
              autoLogin: true,
            ),
          ),
              (r) => false,
        );
      }
    } catch (e) {
      mDialog("${AppLocalizations.of(context)!.translate('password_update_failed')}");
    } finally {
      // setState(() { _isUpdatingPassword = false; });
    }
  }



  @override
  void recoverSuccess(String phoneNumber, String newCode) {
    mToast("${AppLocalizations.of(context)!.translate('password_updated_success')}");

    if (!widget.is_a_process!) {
      CustomerUtils.clearCustomerInformations().whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              presenter: LoginPresenter(LoginView()),
              phone_number: phoneNumber,
              password: newCode,
              autoLogin: true,
            ),
          ),
              (r) => false,
        );
      });
    }
  }

  @override
  void recoverFails() =>
      mDialog("${AppLocalizations.of(context)!.translate('password_reset_failed')}");

  @override
  void toast(String message) => mDialog(message);

  @override
  void onNetworkError() => mDialog("${AppLocalizations.of(context)!.translate('network_error')}");

  @override
  void onSysError({String message = ""}) => mDialog(message);

  @override
  void disableCodeButton(bool isDisabled) {}

  @override
  void keepRequestId(String login, String requestId) {
    _requestId = requestId;
  }

  @override
  void sendVerificationCodeLoading(bool isLoading) {}

  @override
  void userExistsAlready() {}

  void mDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.info_outline, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ]),
          actions: [
            OutlinedButton(
              style: ButtonStyle(
                  side: MaterialStateProperty.all(
                      BorderSide(color: KColors.primaryColor, width: 1))),
              child: Text("OK", style: TextStyle(color: KColors.primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void mToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void showLoading(bool isLoading) {
    // TODO: implement showLoading
  }


}

