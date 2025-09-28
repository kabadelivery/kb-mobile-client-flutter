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

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

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
   String enteredPassword = _controllers.map((c) => c.text).join();
     print(" MDP : "+enteredPassword) ;
    if (enteredPassword.isEmpty) {
      setState(() => errorMessage = "Veuillez entrer votre mot de passe.");
      return;
    }

    if (enteredPassword.length < 4) {
      setState(() => errorMessage = "Le mot de passe doit contenir au moins 4 caractères.");
      return;
    }

    // ✅ Simulate navigation with collected password (old behavior)
    Navigator.of(context).pop({'code': enteredPassword, 'type': widget.type});
  }

  void _jumpToOTPPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>ForgotenPasswordOTP()
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
              const Text(
                "Confirmation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vous allez recevoir un code de vérification pour réinitialiser le mot de passe",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
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
                  child: const Text(
                    "Recevoir le Code",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(FontAwesomeIcons.rightFromBracket, color: KColors.primaryColor, size: 25),
                    SizedBox(width: 10),
                    Text("Connexion",
                        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 40),
                 const Text(
                "Entrez le code de vérification",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
                const SizedBox(height: 20),

                // ✅ Password Field
                /* TextField(
                  controller: _controllers,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock_outline, color: KColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: KColors.primaryColor),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ), */
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOtpField(index)),
              ),
              const SizedBox(height: 20),

              const Text(
                "Un code vous a été envoyé par SMS via le numéro de téléphone que vous avez renseigné.\nCe code expire dans 3 minutes pour votre sécurité.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 30),

                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],

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
                    child: const Text("Creer Un Compte",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                // ✅ Forgot Password
                TextButton(
                  onPressed: () => showReceiveCodeBottomSheet(context),
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: KColors.primaryColor),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 50),
          Image.asset("assets/images/background/Patternlogin.png",
              fit: BoxFit.cover, height: 290),
        ],
      ),
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
