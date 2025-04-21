import 'dart:convert';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


/* Register contract */
class RegisterContract {

  void register(String phone_number, String password, String username, String requestId){}
  void sendVerificationCode(String phoneNumber){}
  void checkVerificationCode(String code, String requestId){}
  void createAccount({String? nickname, String? password, String phone_number="", String email="", String? request_id}) {}
}


class RegisterView {
  void showLoading(bool isLoading){}

  void registerSuccess(String login, String password){}

  void toast(String message){}

  void onNetworkError(){}

  void onSysError({String message=""}){}

  void keepRequestId(String phone_number, String request_id){}

  void disableCodeButton(bool isDisabled){}

  void codeIsOk(bool isOk){}

  void userExistsAlready(){}

  void codeError(){}

  void codeRequestSentOk(){}
}


/* Register presenter */
class RegisterPresenter implements RegisterContract {

  bool isWorking = false;

  late ClientPersonalApiProvider provider;

  RegisterView _registerView;

  RegisterPresenter (this._registerView) {
    provider = new ClientPersonalApiProvider();
  }

  @override
  Future checkVerificationCode(String code, String requestId) async {

    /* */
    if (isWorking)
      return;
    isWorking = true;

    _registerView.showLoading(true);
    var jsonContent = await provider.checkRequestCodeAction(code, requestId);
    int error = mJsonDecode(jsonContent)["error"];

    try {
      if (error == 0) {
        _registerView.codeIsOk(true);
      } else {
        _registerView.codeIsOk(false);
      }
    } catch (_) {
      _registerView.codeIsOk(false);
    }

    isWorking = false;
    _registerView.showLoading(false);
    _registerView.codeRequestSentOk(); /*  */
  }

  @override
  void register(String login, String password, String username, String requestId) {
  }

  @override
  Future sendVerificationCode(String login) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      var jsonContent = await provider.registerSendingCodeAction(login);
      int error = mJsonDecode(jsonContent)["error"];

      if (error == 500) {
        _registerView.userExistsAlready();
      } else if (error == 0) {
        String requestId = json.decode(jsonContent)["data"]["request_id"];
        _registerView.keepRequestId(login, requestId);
      } else {
        _registerView.onSysError(message: json.decode(jsonContent)["message"]);
      }
      isWorking = false;
      _registerView.codeRequestSentOk(); /*  */
    } catch (_) {
      if ("${_.toString()}".contains("-2")) {
        _registerView.codeRequestSentOk();
        _registerView.onNetworkError();
      }
    }
    isWorking = false;
  }

  set registerView(RegisterView value) {
    _registerView = value;
  }

  @override
  Future createAccount({String? nickname, String? password, String? whatsapp_number, String phone_number="", String email="", String? request_id}) async {

    if (isWorking)
      return;
    isWorking = true;

    var jsonContent = await provider.registerCreateAccountAction(nickname:nickname!, password: password!, whatsapp_number: whatsapp_number!, phone_number: phone_number, email: email, request_id: request_id!);
    int error = mJsonDecode(jsonContent)["error"];
    if (error == 0) {
      /* successfully created account */
      /* jump to the login page to login the customer */
      _registerView.registerSuccess(Utils.isEmailValid(email) ? email : phone_number, password);
    } else if (error == 301) {
      _registerView.codeError();
    } else{
      _registerView.onSysError(message: json.decode(jsonContent)["message"]);
    }

    isWorking = false;

  }

}