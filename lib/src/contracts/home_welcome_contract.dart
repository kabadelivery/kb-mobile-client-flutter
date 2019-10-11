


/* login contract */
import 'dart:convert';

import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/resources/app_api_provider.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWelcomeContract {

  Future fetchHomePage (){}
}

class HomeWelcomeView {
  void updateHomeWelcomePage(HomeScreenModel data){}
  void showLoading(bool isLoading) {}
  void showErrorMessage(String message){}
  void sysError(){}
  void networkError(){}
}

/* login presenter */
class HomeWelcomePresenter implements HomeWelcomeContract {

  bool isWorking = false;

  AppApiProvider provider;

  HomeWelcomeView _homeWelcomeView;

  HomeWelcomePresenter() {
    provider = AppApiProvider();
  }

  @override
  Future fetchHomePage() async {

    if (isWorking)
      return;

    isWorking = true;
    try {
      HomeScreenModel _data = await provider.fetchHomeScreenModel();
        _homeWelcomeView.updateHomeWelcomePage(_data);
    } catch(_) {
      if (_ == -2) {
        _homeWelcomeView.networkError();
      } else {
        _homeWelcomeView.showErrorMessage("");
      }
    }
    isWorking = false;
  }


  /* @override
  Future login(String login, String password) async {
    */ /* make network request, create a lib that makes network request. */ /*
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
      CustomerModel customer = CustomerModel.fromJson(obj["data"]["customer"]);
      if (error == 0  && token.length > 0) {
        */ /* login successful */ /*
        _persistTokenAndUserdata(token, customer);
        _loginView.loginSuccess();
      } else {
        */ /* login failure */ /*
        _loginView.loginFailure(message);
      }
    } catch(_) {
      */ /* login failure */ /*
    }
    isWorking = false;
  }
*/
  set homeWelcomeView(HomeWelcomeView value) {
    _homeWelcomeView = value;
  }

}