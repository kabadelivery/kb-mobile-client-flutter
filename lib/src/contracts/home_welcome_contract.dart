


/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWelcomeContract {

  Future fetchHomePage (){}
  Future updateToken (CustomerModel customer) {}
}

class HomeWelcomeView {
  void updateHomeWelcomePage(HomeScreenModel data){}
  void showLoading(bool isLoading) {}
  void showErrorMessage(String message){}
  void sysError(){}
  void networkError(){}
  void tokenUpdateSuccessfully() {}
  void hasUnreadMessages(bool hasNewMessage) {}
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

    CustomerUtils.getOldWelcomePage().then((pageJson) async {

      try {
        _homeWelcomeView.showLoading(true);
        HomeScreenModel _model;
        // load previous page
        try {
          HomeScreenModel _model = HomeScreenModel.fromJson(json.decode(pageJson)["data"]);
          _homeWelcomeView.updateHomeWelcomePage(_model);
        } catch(e){
          print(e);
          _homeWelcomeView.showLoading(true);
        }
        // save it to the shared preferences
        String _dataResponse = await provider.fetchHomeScreenModel();
        _model = HomeScreenModel.fromJson(json.decode(_dataResponse)["data"]);
        _homeWelcomeView.updateHomeWelcomePage(_model);
        CustomerUtils.saveWelcomePage(_dataResponse);
      } catch(_) {
        if (_ == -2) {
          _homeWelcomeView.networkError();
        } else {
          _homeWelcomeView.showErrorMessage("");
        }
      }
      isWorking = false;
    });
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

  @override
  Future updateToken(CustomerModel customer) async {

    try {
     int error = await provider.updateToken(customer);
     if (error == 0) {
       // we have successfully did it.
      _homeWelcomeView.tokenUpdateSuccessfully();
     }
    } catch (_) {
      print(_);
    }
    return null;
  }

  checkUnreadMessages(CustomerModel customer) async {

    try {
      bool hasNewMessage = await provider.checkUnreadMessages(customer);
     _homeWelcomeView.hasUnreadMessages(hasNewMessage);
    } catch (_) {
      print(_);
      _homeWelcomeView.hasUnreadMessages(false);
    }
  }


//    final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
//    String token = await firebaseMessaging.getToken();


}