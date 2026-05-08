import 'dart:async';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/newAuth/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc.dart';
enum OtpType{
  login,
  password_recovery,
  signUp
}
class OtpDialog extends StatefulWidget {
  final OtpType otp_type;
  const OtpDialog({super.key,required this.otp_type});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final Color baseColor = AuthColors.primaryRed;
  String request_id="";
  final List<TextEditingController> controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
  List.generate(4, (_) => FocusNode());
  int secondsLeft = 60;
  Timer? timer;
  AuthBloc authBloc=AuthBloc();
  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(StartOtpTimerEvent());
  }
  String get otpCode {
    return controllers.map((e) => e.text).join();
  }

  bool get isOtpComplete {
    return otpCode.length == 4;
  }

  void validateOtp() {
    if (!isOtpComplete) return;
    if(widget.otp_type==OtpType.login)
      authBloc.add(onLoginOtpEvent(otp: otpCode));
    else if(widget.otp_type==OtpType.password_recovery)
      authBloc.add(onPasswordRecoveryOtpEvent(otp: otpCode));
    else if (widget.otp_type==OtpType.signUp)
      authBloc.add(onSignupOtpEvent(otp: otpCode));
  }

  void resendOtp() {
    authBloc.add(StartOtpTimerEvent());
    if(widget.otp_type==OtpType.login)
      authBloc.add(onSendLoginOtpEvent(login: authBloc.email.isEmpty?authBloc.phoneNumber:authBloc.email,password: authBloc.password,app_version: authBloc.app_version,shouldSendOtp: authBloc.shouldSendOtp));
    else if(widget.otp_type==OtpType.password_recovery)
      authBloc.add(onSendPasswordRecoveryOtpEvent(otp: otpCode));
    else if (widget.otp_type==OtpType.signUp)
      authBloc.add(onSendSignupOtpEvent(otp: otpCode));
  }

  void contactCustomerService() {
    // TODO: contacter le service client
    // authBloc.add(
    //   ContactCustomerServiceEvent(),
    // );
  }
  void resetOtp() {
    for (final controller in controllers) {
      controller.clear();
    }
    focusNodes.first.requestFocus();
    timer?.cancel();

    setState(() {
      secondsLeft = 60;
    });
    authBloc.add(StartOtpTimerEvent());
  }
  @override
  void dispose() {
    timer?.cancel();

    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is OtpInitialState){
          resetOtp();
        }
        if (state is OtpSuccessState) {
          authBloc.saveUser(authBloc.obj, context);
          Navigator.pop(context, true);
        }

        if (state is OtpFailureState) {
          // TODO: afficher snackbar, message d'erreur, etc.
        }
      },
      builder: (context, state) {
        final bool isLoading = state is OtpLoadingState;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: baseColor,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Validation OTP",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vous allez recevoir un code OTP. Entrez le code à 4 chiffres pour continuer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 56,
                      height: 64,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        enabled: !isLoading,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: baseColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            focusNodes[index + 1].requestFocus();
                          }

                          if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }

                          setState(() {});
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                if (secondsLeft > 0)
                  Text(
                    "Renvoyer le code dans ${secondsLeft}s",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Column(
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : resendOtp,
                        child: Text(
                          "Renvoyer l'OTP",
                          style: TextStyle(
                            color: baseColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : contactCustomerService,
                        child: const Text(
                          "Contacter le service client",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isOtpComplete && !isLoading
                        ? validateOtp
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: baseColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        :  Text(
                      AppLocalizations.of(context)!.translate("validate"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                if (state is OtpFailureState)
                  OtpErrorOverlay(
                    message: state.message,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate("cancel"),
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
}
class OtpErrorOverlay extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const OtpErrorOverlay({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFE53935),
    this.textColor = Colors.white,
    this.icon = Icons.error_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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