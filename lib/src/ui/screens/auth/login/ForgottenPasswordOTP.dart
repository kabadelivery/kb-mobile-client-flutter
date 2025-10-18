import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/ui/screens/auth/pwd/NewPasswordPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

import '../../../../contracts/recover_password_contract.dart';

class ForgotenPasswordOTP extends StatefulWidget {
  const ForgotenPasswordOTP({super.key});

  @override
  State<ForgotenPasswordOTP> createState() => _ForgotenPasswordOTPState();
}

class _ForgotenPasswordOTPState extends State<ForgotenPasswordOTP> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  RecoverPasswordPresenter? presenter;


  Timer? _timer;
  int _remainingSeconds = 90;
  bool _showResendOptions = false;
  String _selectedMethod = 'whatsapp';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _remainingSeconds = 90;
    _showResendOptions = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          _showResendOptions = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _submitCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le code complet")),
      );
      return;
    }

    // ✅ Stop timer if code entered
    _timer?.cancel();

    // TODO: Call API verification here
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NewPasswordPage(
        presenter: RegisterPresenter(RegisterView()),
      ),
    ));
  }

  void _openResendOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Recevoir le code via",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile<String>(
                    value: 'whatsapp',
                    groupValue: _selectedMethod,
                    title: const Text("WhatsApp"),
                    onChanged: (value) {
                      setModalState(() => _selectedMethod = value!);
                    },
                  ),
                  RadioListTile<String>(
                    value: 'email',
                    groupValue: _selectedMethod,
                    title: const Text("Email"),
                    onChanged: (value) {
                      setModalState(() => _selectedMethod = value!);
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Code renvoyé via ${_selectedMethod == 'whatsapp' ? 'WhatsApp' : 'Email'} ✅"),
                        ),
                      );
                      _startCountdown();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Envoyer le code"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
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

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(1, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(FontAwesomeIcons.rightFromBracket,
                    color: KColors.primaryColor, size: 25),
                const SizedBox(width: 10),
                Text(
                  "${AppLocalizations.of(context)!.translate('connexion')}",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ]),
              const SizedBox(height: 10),

              const Text(
                "Entrez le code de vérification",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOtpField(index)),
              ),
              const SizedBox(height: 20),

              const Text(
                "Un code vous a été envoyé par SMS via le numéro de téléphone que vous avez renseigné.\nCe code expire dans 1 : 30 seconds pour votre sécurité.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 30),

              // Timer or resend option
              if (!_showResendOptions)
                Text(
                  "⏱ Temps restant : ${_formatTime(_remainingSeconds)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                )
              else
                ElevatedButton(
                  onPressed: _openResendOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: KColors.primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Recevoir le code via…",
                    style: TextStyle(color: KColors.primaryColor),
                  ),
                ),

              const SizedBox(height: 25),

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
                  child: const Text(
                    "Nouveau Mot de Passe",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
