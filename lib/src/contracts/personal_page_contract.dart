


/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonnalPageContract {

}

class PersonnalPageView {

  void updatePersonnalPage(CustomerModel data){}
  void showLoading(bool isLoading) {}
  void showErrorMessage(String message){}
  void sysError(){}
  void networkError(){}
}

/* login presenter */
class PersonnalPagePresenter implements PersonnalPageContract {

  bool isWorking = false;

  late ClientPersonalApiProvider provider;

  PersonnalPageView _personnalPageView;

  PersonnalPagePresenter(this._personnalPageView) {
    provider = ClientPersonalApiProvider();
  }


  @override
  Future updatePersonnalPage(CustomerModel customer) async {

    if (isWorking)
      return;

    isWorking = true;
    try {
      CustomerModel res = await provider.updatePersonnalPage(customer);
      _personnalPageView.updatePersonnalPage(res);
    } catch(_) {
      if (_ == -2) {
        _personnalPageView.networkError();
      } else {
        _personnalPageView.showErrorMessage("");
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
      xrint(jsonContent);
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
  set personnalPageView(PersonnalPageView value) {
    _personnalPageView = value;
  }

}