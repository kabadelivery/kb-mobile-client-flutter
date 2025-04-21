/* login contract */
import 'dart:convert';

import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/xrint.dart';

class LoginContract {

  void login (bool shouldSendOtpCode, String password, String phoneCode, String app_version){}
}

class LoginView {
  void showLoading(bool isLoading) {}
  void loginSuccess (var obj) {}
  void loginPasswordError () {}
  void networkError () {}
  void accountNoExist(String login) {}
  void loginTimeOut() {}
  void systemError() {}
}


/* login presenter */
class LoginPresenter implements LoginContract {

  bool isWorking = false;

  late ClientPersonalApiProvider provider;

  LoginView _loginView;

  LoginPresenter (this._loginView) {
    provider = new ClientPersonalApiProvider();
  }

  @override
  Future login(bool shouldSendOtpCode, String login, String password, String app_version) async {

    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      _loginView.showLoading(true);

      String jsonContent;

      try {
        var obj  = await provider.loginAction(app_version: app_version,
            login: login, password: password, shouldSendOtpCode: shouldSendOtpCode);
        // xrint(jsonContent);
        // var obj = json.decode(data);
        int error = int.parse("${obj["error"]}");
        if (error == 0/* && token != null && token.length > 0*/) {
          /* login successful */
          _loginView.loginSuccess(obj);
        } else if (error == 1) {
          /* login failure */
          _loginView.loginPasswordError();
        } else if (error == -1) {
          _loginView.accountNoExist(login);
        }
      } catch(_) {
        xrint(_);
        if ("${_.toString()}".contains("timed out")) {
          _loginView.loginTimeOut();
        } else if ("${_.toString()}".contains("-2")) {
          _loginView.networkError();
        } else
          _loginView.systemError();
      }
    } catch(_) {
      /* login failure */
      xrint("error ${_}");
      if (_ == -2)
        _loginView.networkError();
      else
        _loginView.networkError();
    }
    isWorking = false;
    _loginView.showLoading(false);
  }

  set loginView(LoginView value) {
    _loginView = value;
  }

}