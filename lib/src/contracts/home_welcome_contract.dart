


/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/AlertMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
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
  void checkVersion (String code, int force, String cl_en, String cl_fr, String cl_zh) {}

  void showBalanceLoading(bool isLoading) {}
  void showBalance(String balance) {}
  void updateKabaPoints(String kabaPoints) {}

  void checkServiceMessage(AlertMessageModel message) {}
}

/* login presenter */
class HomeWelcomePresenter implements HomeWelcomeContract {

  bool isWorking = false;

  AppApiProvider provider;

  HomeWelcomeView _homeWelcomeView;

  bool isFetchBalanceWorking = false;

  HomeWelcomePresenter() {
    provider = AppApiProvider();
  }

  @override
  Future fetchHomePage() async {

    if (isWorking)
      return;

    isWorking = true;

    CustomerUtils.getOldWelcomePage().then((pageJson) async {

      _homeWelcomeView.showLoading(true);
      HomeScreenModel _model;
      // load previous page

      if (pageJson != null) {
        try {
          HomeScreenModel _model = HomeScreenModel.fromJson(
              mJsonDecode(pageJson)["data"]);
          _homeWelcomeView.updateHomeWelcomePage(_model);
        } catch (e) {
          xrint(e);
          _homeWelcomeView.showLoading(true);
        }
      }

      try {
        // save it to the shared preferences
        Map<String, dynamic> _dataResponse = await provider.fetchHomeScreenModel();
        _model = HomeScreenModel.fromJson(_dataResponse["data"]);
        _homeWelcomeView.updateHomeWelcomePage(_model);
        CustomerUtils.saveWelcomePage(json.encode(_dataResponse));
      } catch(_) {
        if (_ == -2) {
          _homeWelcomeView.networkError();
        } else {
          _homeWelcomeView.showErrorMessage("");
        }
      }
      _homeWelcomeView.showLoading(false);
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
      xrint(jsonContent);
      var obj = mJsonDecode(jsonContent);
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
      xrint("============================= ERRRRROOOORRR ====================${_}");
    }
    return null;
  }

  checkUnreadMessages(CustomerModel customer) async {

    try {
      bool hasNewMessage = await provider.checkUnreadMessages(customer);
      _homeWelcomeView.hasUnreadMessages(hasNewMessage);
    } catch (_) {
      xrint(_.toString());
      _homeWelcomeView.hasUnreadMessages(false);
    }
  }

  Future<void> checkVersion() async {
    try {
      Map version = await provider.checkVersion();
      String code = version["version"];
      int force = version["is_required"];
      String cl_en = version["changeLog"]["en"];
      String cl_fr = version["changeLog"]["fr"];
      String cl_zh = version["changeLog"]["zh"];
      _homeWelcomeView.checkVersion(code, force, cl_en, cl_fr, cl_zh);
    } catch (_) {
      /* RestaurantReview failure */
      xrint("error ${_}");
    }
  }

  Future<void> checkServiceMessage() async {
    try {
      Map smessage = await provider.checkServiceMessage();
      _homeWelcomeView.checkServiceMessage(AlertMessageModel.fromMap(smessage));
    } catch (_) {
      /* RestaurantReview failure */
      xrint("error ${_}");
    }
  }

  Future<void> checkBalance(CustomerModel customer) async {

    if (isFetchBalanceWorking)
      return;
    isFetchBalanceWorking = true;
    _homeWelcomeView.showBalanceLoading(true);
    try {
      String balance = await provider.checkBalance(customer);
//      String kabaPoints = await provider.checkKabaPoints(customer);
      // also get the restaurant entity here.
      _homeWelcomeView.showBalance(balance);
//      _homeWelcomeView.updateKabaPoints(kabaPoints);
      isFetchBalanceWorking = false;
    } catch (_) {
      /* Transaction failure */
      xrint("error ${_}");
      if (_ == -2) {
//        _transactionView.balanceSystemError();
      } else {
//        _transactionView.balanceSystemError();
      }
      isFetchBalanceWorking = false;
    }
  }



}