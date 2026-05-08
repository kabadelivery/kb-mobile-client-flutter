import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../microservices/expedition/presentation/widget/popAnimation.dart';
import '../../../utils/_static_data/KTheme.dart';
import 'bloc/auth_bloc.dart';
import 'colors.dart';
class LoginPageV2 extends StatefulWidget {
  const LoginPageV2({super.key});

  @override
  State<LoginPageV2> createState() => _LoginPageV2State();
}

class _LoginPageV2State extends State<LoginPageV2> {
  String hint = "";

  bool isConnecting = false;

  bool isPhoneSelected = true;

  TextEditingController _numberFieldController = new TextEditingController();
  TextEditingController _emailFieldController = new TextEditingController();

  bool _obscurePassword=true;

  TextEditingController _passwordController = new TextEditingController();

  bool _loading = false;

  String selectedCountryCode = '228';

  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _obscureConfirmPassword = true;

  bool isLogin = true;

  AuthBloc authBloc =AuthBloc();

  void initState(){
    super.initState();
    authBloc=context.read<AuthBloc>();
  }
  void resetKey(){
    String tempIdentifier=isPhoneSelected?_emailFieldController.text: _numberFieldController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    _formKey.currentState?.reset();
    if(isPhoneSelected)
      _emailFieldController.text=tempIdentifier;
    else
      _numberFieldController.text=tempIdentifier;
    _passwordController.text=password;
    _confirmPasswordController.text=confirmPassword;
  }
  Future<void> launchLogin()async{
    authBloc.add(LoadingEvent());
    final info = await PackageInfo.fromPlatform();
    final appVersion = info.version;
    authBloc.add(onSendLoginOtpEvent(login: isPhoneSelected? selectedCountryCode+""+_numberFieldController.text.trim():_emailFieldController.text.trim(),
        password: _passwordController.text.trim(),
        app_version: appVersion,
        shouldSendOtp: !kDebugMode
    ));
  }
  Future<void> launchSignUp()async{
    context.read<AuthBloc>().add(
      ConfirmRegister(
        fullName: _fullNameController.text.trim(),
        identifier: isPhoneSelected? selectedCountryCode+""+_numberFieldController.text.trim():_emailFieldController.text.trim(),
        password: _passwordController.text.trim(),
        otp: otpController.text.trim(),
        isPhone: isPhoneSelected,
        countryCode: selectedCountryCode,
      ),
    );
  }
  final OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
      width: 1,
      color: AuthColors.inputBorder,
    ),
  );

  @override
  void dispose() {
    authBloc.add(AuthReset());
    _emailFieldController.dispose();
    _numberFieldController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hint = "${AppLocalizations.of(context)!.translate('login_phonenumber_hint')}";
  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    debugPrint("selectedCountryCode $selectedCountryCode");
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AuthColors.backgroundPage,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Center(
            child:Padding(
              padding: EdgeInsets.all(20) ,
              child:Form(
                key: _formKey,
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    debugPrint('called state :$state');
                    if( state is selectCodeCountryState){
                      selectedCountryCode = state.code;
                    }
                    if(state is ChangeIdentifierState){
                      isPhoneSelected = state.isPhone;
                      resetKey();
                    }
                    if(state is ClickAuthTypeState){
                      isLogin = state.isLogin;
                      resetKey();
                    }

                    if(state is RequiredOtpState){

                    }
                    if (state is AuthOtpSent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }

                    if (state is AuthAuthenticated) {
                      authBloc.saveUser(authBloc.obj, context);
                      isConnecting =false;
                      CherryToast.success(
                        toastPosition: Position.bottom,
                        title: Text(AppLocalizations.of(context)!.translate('auth_success'),style: TextStyle(fontWeight:FontWeight.bold),),
                      ).show(context);
                      Navigator.pop(context);
                    }

                    if (state is AuthRegistered) {
                      // Register success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );

                      // TODO: maybe switch to login or navigate home
                    }

                    if (state is AuthFailure) {
                      CherryToast.error(
                        toastPosition: Position.bottom,
                        title: Text(AppLocalizations.of(context)!.translate(state.message)),
                      ).show(context);
                      isConnecting=false;
                    }
                    if(state is AuthLoading){
                      isConnecting= true;
                    }
                  },

                  builder: (context, state) {
                    isConnecting = state is AuthLoading || state is OtpLoadingState;

                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('assets/images/jpg/kaba-red-white.jpg',width:120),

                            SizedBox(height: 30),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 5 , vertical:5),
                                decoration: BoxDecoration(
                                  color: AuthColors.modeSelectorBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:  Row(
                                  children: [
                                    // PHONE BUTTON
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if(!isPhoneSelected)
                                          authBloc.add(ChangeIdentifier(isPhone: true));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12 ,horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: isPhoneSelected ?AuthColors.activeTabBg : Colors.transparent,
                                             borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10) ,
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 6),
                                              Text(
                                                "${AppLocalizations.of(context)!.translate('phone_call')}",
                                                style: TextStyle(
                                                  color: isPhoneSelected ?  AuthColors.primaryRed :Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // EMAIL BUTTON
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: ()  {
                                        if(isPhoneSelected)
                                        authBloc.add(
                                            ChangeIdentifier(isPhone: false));

                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: !isPhoneSelected ? AuthColors.activeTabBg : Colors.transparent,
                                            //border: Border.all(color: basedColor, width: 1.5),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10) ,
                                              bottomLeft: Radius.circular(10) ,
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.translate('email')}",
                                                style: TextStyle(
                                                  color: isPhoneSelected ? Colors.black54: AuthColors.primaryRed ,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )

                            ),
                            SizedBox(height: 20),
                            isPhoneSelected
                                ? PopInWidget(
                                  duration: Duration(milliseconds: 500),
                                  child: TextFormField(
                                     controller: _numberFieldController,
                                        enabled: !isConnecting,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (value){
                                            authBloc.add(UpdatePhone(text: "${selectedCountryCode}"+value));
                                        },
                                        validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('phone_required');
                                  }
                                  if (selectedCountryCode.contains('228')) {
                                    if (value.trim().length != 8) {
                                      return AppLocalizations.of(context)!
                                          .translate('phone_invalid');
                                    }
                                  }

                                  return null;
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration
                                    (
                                  filled: true,
                                  fillColor: AuthColors.inputBackground,

                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 12,
                                  ),
                                  errorStyle: const TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                  ),
                                  prefixIcon: CountryCodePicker( onChanged: (code) {
                                    setState(() {
                                      authBloc.add(selectCodeCountryEvent(code: code.dialCode??""));;
                                    });
                                    debugPrint("New country selected: ${code.dialCode}"); }, initialSelection: 'TG',
                                    favorite: const ['+228', 'TG'],
                                    showFlag: true,
                                    showDropDownButton: true,
                                    textStyle: const TextStyle(color: Colors.black, fontSize: 14),
                                    showCountryOnly: false, showOnlyCountryWhenClosed: false,
                                    alignLeft: false, ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 100,
                                    maxWidth: 150,
                                  ),
                                  hintText:
                                  AppLocalizations.of(context)!
                                      .translate('enter_phone'),

                                  hintStyle: const TextStyle(fontSize: 14),

                                  border: commonBorder,
                                  enabledBorder: commonBorder,
                                  focusedBorder: commonBorder,
                                                                          ),
                                                                        ),
                                )
                                : PopInWidget(
                              duration: Duration(milliseconds: 500),
                                  child: TextFormField(
                                    controller: _emailFieldController,
                                    enabled: !isConnecting,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (value){
                                      authBloc.add(UpdateEmail(text:value));
                                    },
                                    validator: (value) {

                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .translate('email_required');
                                  }
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return AppLocalizations.of(context)!
                                        .translate('email_invalid');
                                  }
                                  return null;
                                    },
                                    decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AuthColors.inputBackground,
                                  errorStyle: const TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 12,
                                  ),
                                  hintText:
                                  AppLocalizations.of(context)!
                                      .translate('enter_email'),

                                  hintStyle: const TextStyle(fontSize: 14),

                                  border: commonBorder,
                                  enabledBorder: commonBorder,
                                  focusedBorder: commonBorder,
                                                                          ),
                                                                        ),
                                ),
                            if(!isLogin)...[
                              const SizedBox(height: 20),
                              PopInWidget(
                                duration: Duration(milliseconds: 500),
                                child: TextFormField(
                                  controller: _fullNameController,
                                  enabled: !isConnecting,
                                  keyboardType: TextInputType.name,
                                  onChanged: (value){
                                    authBloc.add(UpdateUsername(text:value));
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .translate('full_name_required');
                                    }

                                    if (value.trim().length < 3) {
                                      return AppLocalizations.of(context)!
                                          .translate('full_name_too_short');
                                    }

                                    return null;
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AuthColors.inputBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 12,
                                    ),
                                    errorStyle: const TextStyle(
                                      fontSize: 11,
                                      height: 1,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: AuthColors.textMain.withOpacity(.6),
                                      size: 22,
                                    ),
                                    hintText: AppLocalizations.of(context)!
                                        .translate('username'),
                                    hintStyle: const TextStyle(fontSize: 14),
                                    border: commonBorder,
                                    enabledBorder: commonBorder,
                                    focusedBorder: commonBorder,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 20),
                            PopInWidget(
                              duration: Duration(milliseconds: 500),
                              child: TextFormField(
                                controller: _passwordController,
                                enabled: !isConnecting,
                                onChanged: (value){
                                  authBloc.add(UpdatePassword(text:value));
                                },
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
                                obscureText: _obscurePassword,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: AuthColors.inputBackground,
                                  enabled: _passwordController.text.length!=4,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 12,
                                  ),
                                  errorStyle: const TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      color: AuthColors.textMain.withOpacity(.5),
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

                                  hintText:
                                  AppLocalizations.of(context)!
                                      .translate('command_key'),

                                  hintStyle: const TextStyle(fontSize: 14),

                                  border: commonBorder,
                                  enabledBorder: commonBorder,
                                  focusedBorder: commonBorder,
                                ),
                              ),
                            ),
                            if(!isLogin)...[
                              SizedBox(height: 20),
                              PopInWidget(
                                duration: Duration(milliseconds: 700),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _confirmPasswordController,
                                  enabled: !isConnecting,
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

                                  obscureText: _obscureConfirmPassword,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(fontSize: 14),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    errorStyle: const TextStyle(
                                      fontSize: 11,
                                      height: 1,
                                    ),
                                    filled: true,
                                    fillColor: AuthColors.inputBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 12,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AuthColors.textMain.withOpacity(.6),
                                      size: 22,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        color: AuthColors.textMain.withOpacity(.6),
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
                                    hintText: AppLocalizations.of(context)!
                                        .translate('confirm_password'),
                                    hintStyle: const TextStyle(fontSize: 14),
                                    border: commonBorder,
                                    enabledBorder: commonBorder,
                                    focusedBorder: commonBorder,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Column(
                                    children:[
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:  AuthColors.primaryRed,
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          onPressed: () async{
                                            if(_formKey.currentState!.validate()){
                                              if (isLogin) {
                                                  await launchLogin();
                                              } else {
                                               await launchSignUp();
                                              }
                                            }
                                          },
                                          child: isConnecting
                                              ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : Text(
                                            "${AppLocalizations.of(context)!.translate('connexion')}",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      if(isLogin)...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(AppLocalizations.of(context)!.translate('no_account_yet'),style: TextStyle(fontWeight: FontWeight.w300,color: AuthColors.textMain),),
                                            SizedBox(width: 5),
                                            GestureDetector(
                                                onTap: (){
                                                 authBloc.add(ClickAuthTypeEvent(isLogin: !isLogin));
                                                },
                                                child: Text(AppLocalizations.of(context)!.translate('signup'),style: TextStyle(fontWeight: FontWeight.bold,color: AuthColors.primaryRed),))
                                          ],
                                        ),
                                        SizedBox(height:30),
                                        GestureDetector(
                                          onTap: (){
                                            //TODO GO TO LOGIN PAGE
                                          },
                                          child: Text(AppLocalizations.of(context)!.translate("forgot_password"),style: TextStyle(color:AuthColors.textMain.withOpacity(.5),
                                              decorationStyle:TextDecorationStyle.solid,
                                              decoration: TextDecoration.underline,
                                              decorationColor: AuthColors.textMain.withOpacity(.5))),
                                        )

                                      ]
                                      else...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(AppLocalizations.of(context)!.translate('already_have_an_accoun'),style: TextStyle(fontWeight: FontWeight.w300,color: AuthColors.textMain),),
                                            SizedBox(width: 5),
                                            GestureDetector(
                                                onTap: (){
                                                  authBloc.add(ClickAuthTypeEvent(isLogin: !isLogin));
                                                },
                                                child: Text(AppLocalizations.of(context)!.translate('login_button'),style: TextStyle(fontWeight: FontWeight.bold,color: AuthColors.primaryRed),))
                                          ],
                                        )
                                      ],
                                    ]
                                ),
                            SizedBox(height: 30),

                          ]
                                );
                  },
                ),
              ),
            )
          )
        ));
  }
}
