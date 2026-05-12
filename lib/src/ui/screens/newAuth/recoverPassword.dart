import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/app/app.dart';

import '../../../localizations/AppLocalizations.dart';
import 'bloc/auth_bloc.dart';
import 'colors.dart';
import 'otpPopupPage.dart';

class RecoverPasswordPageV2 extends StatefulWidget {
  final String? login;

  const RecoverPasswordPageV2({
    super.key,
    this.login,
  });

  @override
  State<RecoverPasswordPageV2> createState() => _RecoverPasswordPageV2State();
}

class _RecoverPasswordPageV2State extends State<RecoverPasswordPageV2> {
  final _formKey = GlobalKey<FormState>();
  bool _isOtpDialogOpen = false;
  late AuthBloc authBloc;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool isPhoneSelected = true;
  bool otpValidated = false;
  bool _otpWasRequested = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String selectedCountryCode = "228";

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();

    final initialLogin = widget.login?.trim() ?? "";

    if (initialLogin.contains("@")) {
      isPhoneSelected = false;
      _emailController.text = initialLogin;
    } else if (initialLogin.isNotEmpty) {
      isPhoneSelected = true;

      if (initialLogin.startsWith("228") && initialLogin.length > 8) {
        _phoneController.text = initialLogin.substring(3);
      } else {
        _phoneController.text = initialLogin;
      }
    }
  }
  bool get _hasDialogOpen {
    return ModalRoute.of(context)?.isCurrent != true;
  }
  String get login {
    if (isPhoneSelected) {
      return "$selectedCountryCode${_phoneController.text.trim()}";
    }

    return _emailController.text.trim();
  }

  Future<void> sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    _otpWasRequested = true;

    authBloc.add(SendPasswordRecoveryOtpEvent(login: login));
  }

  void resetPassword() {
    if (!_formKey.currentState!.validate()) return;

    authBloc.add(
      ResetPasswordEvent(
        login: login,
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  OutlineInputBorder get commonBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        width: 1,
        color: AuthColors.inputBorder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color:AuthColors.textMain),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      backgroundColor: AuthColors.backgroundPage,
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is RequiredOtpState &&
                state.type == OtpType.password_recovery &&
                _otpWasRequested &&
                !_isOtpDialogOpen &&
                !_hasDialogOpen &&
                !otpValidated) {
              _isOtpDialogOpen = true;
              _otpWasRequested = false;

              final result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                routeSettings: const RouteSettings(name: 'otp_dialog'),
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: OtpDialog(
                    phoneIsSelected: isPhoneSelected,
                    otp_type: state.type,
                  ),
                ),
              );

              if (!mounted) return;

              _isOtpDialogOpen = false;

              if (result == true) {
                setState(() {
                  otpValidated = true;
                });
              }
            }

            if (state is PasswordRecoveryOtpVerifiedState) {
              setState(() {
                otpValidated = true;
              });
            }

            if (state is PasswordResetSuccessState) {
              CherryToast.success(
                toastPosition: Position.bottom,
                title: Text(
                  AppLocalizations.of(context)!.translate(state.message),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ).show(context);
              Navigator.pop(context, true);
            }

            if (state is PasswordResetFailureState) {
              CherryToast.error(
                toastPosition: Position.bottom,
                title: Text(
                  AppLocalizations.of(context)!.translate(state.message),
                ),
              ).show(context);
            }
            if(state is ChangeIdentifierState){
              isPhoneSelected = state.isPhone;
            }
          },
          builder: (context, state) {
            final bool isLoading = state is OtpLoadingState ||
                state is PasswordResetLoadingState ||
                state is AuthLoading;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                  
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 72,
                        color: AuthColors.primaryRed,
                      ),
                  
                      const SizedBox(height: 20),
                  
                      Text(
                        otpValidated
                            ? AppLocalizations.of(context)!.translate('resetPasswordTitle')
                            : AppLocalizations.of(context)!.translate('resetPasswordTitle'),
                  
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  
                      const SizedBox(height: 10),
                  
                      Text(
                        otpValidated
                            ? AppLocalizations.of(context)!.translate("setup_password")
                            :AppLocalizations.of(context)!.translate("recoverAccountTitle")
                            ,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                  
                      const SizedBox(height: 30),
                  
                      if (!otpValidated)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AuthColors.modeSelectorBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                    authBloc.add(ChangeIdentifier(isPhone: !isPhoneSelected));
                                  },
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isPhoneSelected
                                          ? AuthColors.activeTabBg
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.translate("phone_call"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isPhoneSelected
                                            ? AuthColors.primaryRed
                                            : Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                    setState(() {
                                      isPhoneSelected = false;
                                    });
                                  },
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isPhoneSelected
                                          ? AuthColors.activeTabBg
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.translate("email"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !isPhoneSelected
                                            ? AuthColors.primaryRed
                                            : Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                      if (!otpValidated) const SizedBox(height: 20),
                  
                      if (isPhoneSelected)
                        TextFormField(
                          controller: _phoneController,
                          enabled: false,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AuthColors.inputBackground,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: AppLocalizations.of(context)!
                                .translate('enter_phone'),
                            border: commonBorder,
                            enabledBorder: commonBorder,
                            focusedBorder: commonBorder,
                          ),
                        )
                      else
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value){
                            authBloc.add(UpdateEmail(text:value));
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: AuthColors.inputBackground,
                            hintText: AppLocalizations.of(context)!
                                .translate('enter_email'),
                            border: commonBorder,
                            enabledBorder: commonBorder,
                            focusedBorder: commonBorder,
                          ),
                        ),
                  
                      if (otpValidated) ...[
                        const SizedBox(height: 20),
                  
                        TextFormField(
                          controller: _passwordController,
                          enabled: !isLoading,
                          obscureText: _obscurePassword,
                          onChanged: (value){
                            authBloc.add(UpdatePassword(text:value));
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .translate('password_required');
                            }
                  
                            if (value.length < 4) {
                              return AppLocalizations.of(context)!
                                  .translate('password_min_length');
                            }
                  
                            return null;
                          },
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: AuthColors.inputBackground,
                            hintText: AppLocalizations.of(context)!
                                .translate('command_key'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: commonBorder,
                            enabledBorder: commonBorder,
                            focusedBorder: commonBorder,
                          ),
                        ),
                  
                        const SizedBox(height: 20),
                  
                        TextFormField(
                          controller: _confirmPasswordController,
                          enabled: !isLoading,
                          obscureText: _obscureConfirmPassword,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .translate('confirm_password_required');
                            }
                  
                            if (value != _passwordController.text) {
                              return AppLocalizations.of(context)!
                                  .translate('passwords_do_not_match');
                            }
                  
                            return null;
                          },
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: AuthColors.inputBackground,
                            hintText: AppLocalizations.of(context)!
                                .translate('confirm_password'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: commonBorder,
                            enabledBorder: commonBorder,
                            focusedBorder: commonBorder,
                          ),
                        ),
                      ],
                  
                      const SizedBox(height: 30),
                  
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : otpValidated
                              ? resetPassword
                              : sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuthColors.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
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
                              : Text(
                            otpValidated
                                ? AppLocalizations.of(context)!.translate('resetPasswordButton')
                                : AppLocalizations.of(context)!.translate('sendCodeButton')
                               ,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}