import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/pwd/NewPasswordPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

class ForgotenPasswordOTP extends StatefulWidget {
  const ForgotenPasswordOTP({super.key});

  @override
  State<ForgotenPasswordOTP> createState() => _ForgotenPasswordOTPState();
}

class _ForgotenPasswordOTPState extends State<ForgotenPasswordOTP> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  void _submitCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le code complet")),
      );
      return;
    }

    // TODO: Call API verification here
    Navigator.of(context).pop();
    
  }

  void _resendCode() {
    // TODO: Call resend API here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nouveau code envoyé ✅")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Title
             Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       Icon(FontAwesomeIcons.rightFromBracket, color: KColors.primaryColor, size:25),
                       SizedBox(width: 10),
                        Text("${AppLocalizations.of(context)!.translate('connexion')}", style:TextStyle(color:Colors.black, fontSize: 20 , fontWeight: FontWeight.w600 )),
                        SizedBox(width: 5),
                        //Text("${AppLocalizations.of(context)!.translate('name_app')}", style:TextStyle(color:KColors.primaryColor, fontSize: 23 , fontWeight: FontWeight.bold )),
                      ],
                    ),
              const SizedBox(height: 10),

              const Text(
                "Entrez le code de vérification",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),

              // OTP input fields
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

              // Submit button
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
                onPressed :() {
                 Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>NewPasswordPage(presenter: RegisterPresenter(RegisterView()),)
                        ),
                  );
                },
                  child: const Text(
                    "Nouveau Mot de Passe",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Resend code link
              TextButton(
                onPressed: _resendCode,
                child: const Text(
                  "Renvoyer le code",
                  style: TextStyle(color: KColors.primaryColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
