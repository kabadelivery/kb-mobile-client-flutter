import 'dart:convert';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/xrint.dart';


/* Register contract */
class RecoverPasswordContract {

  void sendVerificationCode(String phoneNumber){}
  void checkVerificationCode(String code, String requestId){}
  void updatePassword(String phoneNumber, String newCode, String requestId) {}
}


class RecoverPasswordView {
  void showLoading(bool isLoading){}

//  void registerSuccess(String login, String password){}
  void toast(String message){}
  void onNetworkError(){}
  void onSysError({String message=""}){}
  void keepRequestId(String phone_number, String request_id){}
  void disableCodeButton(bool isDisabled){}
  void codeIsOk(bool isOk){}
  void sendVerificationCodeLoading(bool isLoading) {}
  void recoverSuccess(String phoneNumber, String newCode) {}
  void recoverFails() {}
}


/* Register presenter */
class RecoverPasswordPresenter implements RecoverPasswordContract {

  bool isWorking = false;

  late ClientPersonalApiProvider provider;

  RecoverPasswordView _recoverPasswordView;

  RecoverPasswordPresenter(this._recoverPasswordView) {
    provider = new ClientPersonalApiProvider();
  }

  @override
  Future checkVerificationCode(String code, String requestId) async {

    /* */
    if (isWorking)
      return;
    isWorking = true;

    _recoverPasswordView.sendVerificationCodeLoading(true); /*  */

    String jsonContent = await provider.checkRecoverPasswordRequestCodeAction(code, requestId);
    int error = json.decode(jsonContent)["error"];
    try {
      if (error == 0) {
        _recoverPasswordView.codeIsOk(true);
      } else {
        _recoverPasswordView.codeIsOk(false);
      }
    } catch (_) {
      _recoverPasswordView.codeIsOk(false);
    }
    isWorking = false;
    _recoverPasswordView.sendVerificationCodeLoading(false); /*  */
  }


  @override
  Future sendVerificationCode(String phone_number) async {
    if (isWorking)
      return;
    isWorking = true;
    _recoverPasswordView.sendVerificationCodeLoading(true);
    String jsonContent = await provider.recoverPasswordSendingCodeAction(
        phone_number);
    int error = json.decode(jsonContent)["error"];
    if (error == -1) {
      _recoverPasswordView.onSysError(message: "Sorry, user doesn't exist.");
    } else if (error == 0) {
      String requestId = json.decode(jsonContent)["data"]["request_id"];
      _recoverPasswordView.keepRequestId(phone_number, requestId);
    } else {
      _recoverPasswordView.onSysError(
          message: json.decode(jsonContent)["message"]);
    }
    isWorking = false;
    _recoverPasswordView.sendVerificationCodeLoading(false); /*  */
  }

  set recoverPasswordView(RecoverPasswordView value) {
    _recoverPasswordView = value;
  }

  @override
  Future<void> updatePassword(String login, String newCode,
      String requestId) async {
// post it to the server.
    if (isWorking)
      return;
    isWorking = true;
    _recoverPasswordView.sendVerificationCodeLoading(true);
    try {
      String jsonContent = await provider.passwordResetAction(
          login, newCode, requestId);
      _recoverPasswordView.sendVerificationCodeLoading(false);
      int error = json.decode(jsonContent)["error"];
      if (error == 0) {
        _recoverPasswordView.recoverSuccess(login, newCode);
      } else {
        _recoverPasswordView.recoverFails();
      }
    } catch (_) {
      _recoverPasswordView.sendVerificationCodeLoading(false);
      xrint(_.toString());
      _recoverPasswordView.recoverFails();
    }
    isWorking = false;
  }
}