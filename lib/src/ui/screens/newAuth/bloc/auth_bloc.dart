import 'dart:async';
import 'dart:convert';

import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/ui/screens/newAuth/otpPopupPage.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../../../StateContainer.dart';
import '../../../../models/CustomerModel.dart';
import '../../../../utils/functions/CustomerUtils.dart';
import '../../../../utils/functions/Utils.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _otpTimer;
  int _secondsLeft = 60;

  String email = "";
  String phoneNumber = "";
  String password = "";
  String username = "";
  bool isOtpRequired=true;
  String otpReceived='';
  bool success=false;
  String app_version='';
  bool shouldSendOtp=true;
  String requestId="";
  dynamic obj;
  String recoveryLogin = "";
  String recoveryRequestId = "";
  bool isPhone=true;
  void saveUser(obj,context){
    String token = obj["data"]["payload"]["token"];
    CustomerUtils.persistTokenAndUserdata(token, json.encode(obj));
    CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
    StateContainer
        .of(context)
        .updateLoggingState(state: 1);
    StateContainer.of(context).customer = customer;
  }
  AuthBloc() : super(AuthInitial()) {
    on<StopOtpTimerEvent>((event, emit) {
      _otpTimer?.cancel();
    });
    on<AuthEvent>((event, emit) async {
      if(event is selectCodeCountryEvent){
        emit(selectCodeCountryState(code:event.code.replaceFirst("+", ""),));
      }
      if (event is UpdateEmail) {
        email = event.text;
      }
      if (event is UpdateUsername) {
        username = event.text;
      }

      if (event is UpdatePassword) {
        password = event.text;
      }

      if (event is UpdatePhone) {
        phoneNumber = event.text;
      }

      if (event is ChangeIdentifier) {
        isPhone = event.isPhone;
        emit(ChangeIdentifierState(isPhone: event.isPhone));
      }

      else if (event is ClickAuthTypeEvent) {
        emit(ClickAuthTypeState(isLogin: event.isLogin));
      }

      else if (event is OtpInitEvent) {
        emit(OtpInitialState());
      }
      else if (event is onLoginOtpEvent) {
        try{
          emit(OtpLoadingState());

          if (event.otp.isNotEmpty) {
            ClientPersonalApiProvider provider = ClientPersonalApiProvider();
            var result = await provider.checkRequestCodeAction(event.otp,requestId);
            int error = mJsonDecode(result)["error"];
            int code = mJsonDecode(result)["code"];
            if(error==0){
              add(onSendLoginOtpEvent(
                  login:!isPhone?email:phoneNumber,
                  password:password,
                  app_version:app_version,
                  shouldSendOtp:false
              ));
            }else if(error==500 && code==404){
              emit(ClickAuthTypeState(isLogin: false));
              emit(AuthFailure(message: "user_exists"));
            }else{
              emit(AuthFailure(message: "invalid_otp"));
            }
          } else {
            emit(OtpFailureState(message: "enter_otp"));
          }
        }on TimeoutException {
          emit(AuthFailure(message: "request_timeout"));
        } catch(e){
          debugPrint("Error onLoginOtpEvent $e");
          emit(AuthFailure(message: 'system_error'));
        }
      }

      else if (event is onSignupOtpEvent) {
        emit(OtpLoadingState());
        if (event.otp.isNotEmpty) {
          try{
            ClientPersonalApiProvider provider = ClientPersonalApiProvider();
            var result = await provider.checkRequestCodeAction(event.otp,requestId).timeout(const Duration(seconds: 20));;
            int error = mJsonDecode(result)["error"];
            if(error==0){
              var register = await provider.registerCreateAccountAction(
                nickname: username,
                password: password,
                phone_number: phoneNumber,
                email: email,
                request_id: requestId
              ).timeout(const Duration(seconds: 20));;
              int error = mJsonDecode(register)["error"];
              String message = mJsonDecode(register)["message"];
              if(error==0){
                isOtpRequired=false;
                shouldSendOtp=false;
                emit(OtpSuccessState());
                add(onSendLoginOtpEvent(
                 login:!isPhone?email:phoneNumber,
                 password:password,
                 app_version:app_version,
                 shouldSendOtp:false
                ));
              }else if(error==500 && message.contains("exist")){
                emit(AuthFailure(message: "user_exists"));
              }else{
                emit(AuthFailure(message: "registration_failed"));
              }
            }else{
              emit(OtpFailureState(message: "otp_failed"));
            }
          }on TimeoutException {
            emit(AuthFailure(message: "request_timeout"));
          } catch(e){
            debugPrint('Error $e onSignupOtpEvent');
            emit(AuthFailure(message: "system_error"));
          }

        } else {
          emit(OtpFailureState(message: "enter_otp"));
        }
      }

      else if (event is onSendLoginOtpEvent) {
        emit(AuthLoading());
        try{
          if (event.login.isNotEmpty && event.password.isNotEmpty) {

            ClientPersonalApiProvider provider = ClientPersonalApiProvider();
            shouldSendOtp = event.shouldSendOtp;
            app_version=event.app_version;
            var result = await provider.loginAction(
                login: event.login,
                password: event.password,
                app_version: event.app_version,
                shouldSendOtpCode: event.shouldSendOtp
            ).timeout(const Duration(seconds: 20));;
            int error = int.parse("${result["error"]}");
            if (error == 0) {
              isOtpRequired = result['require_otp']??false;
              if(isOtpRequired){
                requestId = result['request_id'];
                otpReceived = result['login_code'].toString();
                emit(RequiredOtpState(type: OtpType.login));
              }
              else {
                success =true;
                obj = result;
                if (isOtpRequired) {
                  emit(RequiredOtpState(type: OtpType.login));
                }else{
                  emit(AuthAuthenticated());
                }
              }
            }
            else if(error==1 && result['code']==401){
              emit(AuthFailure(message: "login_error"));
            }else if(error==500 &&  result['code']==404){
              emit(AuthFailure(message: "account_no_exists"));
            }
            else{
              emit(AuthFailure(message: "failed_to_send_otp"));
            }
          } else {
            emit(AuthFailure(message: "failed_to_send_otp"));
          }
        }on TimeoutException {
          emit(AuthFailure(message: "request_timeout"));
        } catch(e){
          emit(AuthFailure(message: 'system_error'));
        }
      }
      else if (event is onSendSignupOtpEvent) {
        emit(OtpLoadingState());
        try{
          ClientPersonalApiProvider provider = ClientPersonalApiProvider();
          var jsonContent  = await provider.registerSendingCodeAction(!isPhone?email:phoneNumber).timeout(const Duration(seconds: 20));;
          int error = mJsonDecode(jsonContent)["error"];
          if(error==0){
            requestId = json.decode(jsonContent)["data"]["request_id"];
            otpReceived = json.decode(jsonContent)["data"]["code"].toString();
            emit(RequiredOtpState(type: OtpType.signUp));
          }
          else if(error==500){
            emit(AuthFailure(message: "user_exists"));
          }
          else{
            emit(AuthFailure(message: "failed_to_send_otp"));
          }

        }on TimeoutException {
          emit(AuthFailure(message: "request_timeout"));
        } catch(e){
          debugPrint("Error onSendSignupOtpEvent : $e");
          emit(AuthFailure(message: "system_error"));
        }
      }
      else if (event is StartOtpTimerEvent) {
        _otpTimer?.cancel();
        _secondsLeft = 60;

        emit(OtpTimerRunningState(secondsLeft: _secondsLeft));

        _otpTimer = Timer.periodic(
          const Duration(seconds: 1),
              (_) {
            add(TickOtpTimerEvent());
          },
        );
      }

      else if (event is TickOtpTimerEvent) {
        if (_secondsLeft <= 1) {
          _otpTimer?.cancel();
          _secondsLeft = 0;

          emit(OtpTimerFinishedState());
        } else {
          _secondsLeft--;

          emit(OtpTimerRunningState(secondsLeft: _secondsLeft));
        }
      }

      else if (event is AuthReset) {
        _otpTimer?.cancel();
        _secondsLeft = 60;
         email = "";
         phoneNumber = "";
         password = "";
         username = "";
         isOtpRequired=true;
         otpReceived='';
         success=false;
          recoveryLogin = "";
          recoveryRequestId = "";
         app_version='';
         shouldSendOtp=true;
         obj=null;
        emit(AuthInitial());
      }
      else if (event is SendPasswordRecoveryOtpEvent) {
        emit(OtpLoadingState());

        try {
          recoveryLogin = event.login;

          final provider = ClientPersonalApiProvider();

          final result = await provider.recoverPasswordSendingCodeAction(
            event.login,
          ).timeout(const Duration(seconds: 20));;

          final jsonResult = mJsonDecode(result);
          final int error = jsonResult["error"];

          if (error == 0) {
            recoveryRequestId = jsonResult["data"]["request_id"].toString();

            emit(RequiredOtpState(type: OtpType.password_recovery));
          } else if (error==-1 && jsonResult['code']==401){
            emit(PasswordResetFailureState(message: "account_no_exists"));
          }
            else {
            emit(PasswordResetFailureState(message: "failed_to_send_otp"));
          }
        } on TimeoutException {
          emit(PasswordResetFailureState(message: "request_timeout"));
        }
        catch (e) {
          debugPrint("SendPasswordRecoveryOtpEvent error: $e");
          emit(PasswordResetFailureState(message: "system_error"));
        }
      }

      else if (event is VerifyPasswordRecoveryOtpEvent) {
        emit(OtpLoadingState());

        if (event.otp.isEmpty) {
          emit(OtpFailureState(message: "enter_otp"));
          return;
        }

        try {
          final provider = ClientPersonalApiProvider();

          final result = await provider.checkRecoverPasswordRequestCodeAction(
            event.otp,
            recoveryRequestId,
          ).timeout(const Duration(seconds: 20));;

          final jsonResult = mJsonDecode(result);
          final int error = jsonResult["error"];

          if (error == 0) {
            emit(PasswordRecoveryOtpVerifiedState());
          } else {
            emit(OtpFailureState(message: "otp_failed"));
          }
        } on TimeoutException {
          emit(AuthFailure(message: "request_timeout"));
        } catch (e) {
          debugPrint("VerifyPasswordRecoveryOtpEvent error: $e");
          emit(AuthFailure(message: "system_error"));
        }
      }

      else if (event is ResetPasswordEvent) {
        password = event.password;
        emit(PasswordResetLoadingState());
        try {
          final provider = ClientPersonalApiProvider();

          final result = await provider.passwordResetAction(
            event.login,
            event.password,
            recoveryRequestId,
          ).timeout(const Duration(seconds: 20));;

          final jsonResult = mJsonDecode(result);
          final int error = jsonResult["error"];

          if (error == 0) {
            emit(PasswordResetSuccessState(message: "password_updated_success"));
          }  else if (error==-1 && jsonResult['code']==401){
            emit(PasswordResetFailureState(message: "account_no_exists"));
          }
          else {
            emit(PasswordResetFailureState(message: "password_recover_fails"));
          }
        }  on TimeoutException {
          emit(PasswordResetFailureState(message: "request_timeout"));
        }
        catch (e) {
          debugPrint("ResetPasswordEvent error: $e");
          emit(PasswordResetFailureState(message: "system_error"));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}