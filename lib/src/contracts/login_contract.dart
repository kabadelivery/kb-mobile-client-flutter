/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginContract {

  void login (String password, String phoneCode){}
}

class LoginView {
  void showLoading(bool isLoading) {}
  void loginSuccess () {}
  void loginFailure (String message) {}
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
  Future login(String login, String password) async {

    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      _loginView.showLoading(true);
    String jsonContent = await provider.loginAction(
        login: login, password: password);
      print(jsonContent);
      var obj = json.decode(jsonContent);
      int error = obj["error"];
      String token = obj["data"]["payload"]["token"];
      String message = obj["message"];
      if (error == 0  && token.length > 0) {
        /* login successful */
        CustomerUtils.persistTokenAndUserdata(token, jsonContent);
        _loginView.loginSuccess();
      } else {
        /* login failure */
        _loginView.loginFailure(message);
      }
    } catch(_) {
      /* login failure */
      print("error ${_}");
      if (_ == -2)
      _loginView.loginFailure("Identifiants incorrects");
     else
        _loginView.loginFailure("System error");
    }
    isWorking = false;
    _loginView.showLoading(false);
  }

  set loginView(LoginView value) {
    _loginView = value;
  }

}