import 'dart:async';
import 'dart:convert';

import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../../../StateContainer.dart';
import '../../../../models/CustomerModel.dart';
import '../../../../utils/functions/CustomerUtils.dart';

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
  dynamic obj;
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
        emit(ChangeIdentifierState(isPhone: event.isPhone));
      }

      else if (event is ClickAuthTypeEvent) {
        emit(ClickAuthTypeState(isLogin: event.isLogin));
      }

      else if (event is OtpInitEvent) {
        emit(OtpInitialState());
      }

      else if (event is onPasswordRecoveryOtpEvent) {
        emit(OtpLoadingState());

        if (event.otp.isNotEmpty) {
          emit(OtpSuccessState());
        } else {
          emit(OtpFailureState(message: "Please enter OTP"));
        }
      }

      else if (event is onLoginOtpEvent) {
        emit(OtpLoadingState());

        if (event.otp.isNotEmpty) {
          emit(OtpSuccessState());
        } else {
          emit(OtpFailureState(message: "Please enter OTP"));
        }
      }

      else if (event is onSignupOtpEvent) {
        emit(OtpLoadingState());

        if (event.otp.isNotEmpty) {
          emit(OtpSuccessState());
        } else {
          emit(OtpFailureState(message: "Please enter OTP"));
        }
      }

      else if (event is onSendPasswordRecoveryOtpEvent) {
        emit(OtpLoadingState());

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
            );
            int error = int.parse("${result["error"]}");
            if (error == 0) {
              isOtpRequired = result['require_otp']??false;

              if(isOtpRequired){
                emit(RequiredOtpState());
                otpReceived = result['login_code'];
              }
              else {
                success =true;
                obj = result;
                if (isOtpRequired) {
                  emit(OtpSuccessState());
                }else{
                  emit(AuthAuthenticated());
                }
              }
            }else{
              emit(AuthFailure(message: "Failed to send OTP"));
            }
          } else {
            emit(AuthFailure(message: "Failed to send OTP"));
          }
        }catch(e){
          emit(AuthFailure(message: 'system_error'));
        }
      }
      else if (event is onSendSignupOtpEvent) {
        emit(OtpLoadingState());

        if (event.otp.isNotEmpty) {
          emit(OtpSuccessState());
        } else {
          emit(OtpFailureState(message: "Failed to send signup OTP"));
        }
      }

      else if (event is RequestLoginOtp) {
        emit(AuthLoading());

        emit(AuthOtpSent(
          message: "Login OTP sent successfully",
          isRegister: false,
        ));

        add(StartOtpTimerEvent());
      }

      else if (event is VerifyLoginOtp) {
        emit(AuthLoading());

        if (event.otp.isNotEmpty) {
          emit(OtpSuccessState());
        } else {
          emit(AuthFailure(message: "Invalid OTP"));
        }
      }
      else if (event is RequestRegisterOtp) {
        emit(AuthLoading());

        emit(AuthOtpSent(
          message: "Register OTP sent successfully",
          isRegister: true,
        ));

        add(StartOtpTimerEvent());
      }

      else if (event is ConfirmRegister) {
        emit(AuthLoading());

        if (event.otp.isNotEmpty) {
          emit(AuthRegistered(message: "Registration successful"));
        } else {
          emit(AuthFailure(message: "Invalid OTP"));
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
         app_version='';
         shouldSendOtp=true;
         obj=null;
        emit(AuthInitial());
      }
    });
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}