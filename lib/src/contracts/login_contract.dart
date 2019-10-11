


/* login contract */
import 'dart:convert';

import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
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
    String jsonContent = await provider.loginAction(
        login: login, password: password);
    try {
      print(jsonContent);
      var obj = json.decode(jsonContent);
      int error = obj["error"];
      String token = obj["data"]["payload"]["token"];
      String message = obj["message"];
//      CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
      if (error == 0  && token.length > 0) {
        /* login successful */
       _persistTokenAndUserdata(token, jsonContent);
        _loginView.loginSuccess();
      } else {
        /* login failure */
        _loginView.loginFailure(message);
      }
    } catch(_) {
      /* login failure */
      print("error ${_}");
    }
    isWorking = false;
  }

  set loginView(LoginView value) {
    _loginView = value;
  }

  _persistTokenAndUserdata(String token, String loginResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("_loginResponse", loginResponse);
    /* no need to commit */
    /* expiration date in 3months */
    String expDate = DateTime.now().add(Duration(days: 90)).toIso8601String();
    prefs.setString("_login_expiration_date", expDate);
    print(expDate);
  }


}