/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginContract {

  void login (String password, String phoneCode, String app_version){}
}

class LoginView {
  void showLoading(bool isLoading) {}
  void loginSuccess () {}
  void loginPasswordError () {}
  void networkError () {}
  void accountNoExist() {}
}


/* login presenter */
class LoginPresenter implements LoginContract {

  bool isWorking = false;

  ClientPersonalApiProvider provider;

  LoginView _loginView;

  LoginPresenter () {
    provider = new ClientPersonalApiProvider();
  }

  @override
  Future login(String login, String password, String app_version) async {

    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      _loginView.showLoading(true);

    String jsonContent;

      try {
        jsonContent = await provider.loginAction(app_version: app_version,
            login: login, password: password);
        print(jsonContent);
        var obj = json.decode(jsonContent);
        int error = obj["error"];
        if (error == 0/* && token != null && token.length > 0*/) {
          /* login successful */
          String token = obj["data"]["payload"]["token"];
          CustomerUtils.persistTokenAndUserdata(token, jsonContent);
          _loginView.loginSuccess();
        } else {
          /* login failure */
          _loginView.accountNoExist();
        }
      } catch(_) {
        print(_);
        _loginView.loginPasswordError();
      }
    } catch(_) {
      /* login failure */
      print("error ${_}");
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