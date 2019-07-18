import 'package:flutter/material.dart';
import 'package:kaba_flutter/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:kaba_flutter/screens/auth/register/RegisterPage.dart';
import 'package:kaba_flutter/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:kaba_flutter/screens/home/me/address/EditAddressPage.dart';
import 'package:kaba_flutter/screens/home/me/address/MyAddressesPage.dart';
import 'package:kaba_flutter/screens/home/me/money/MySoldePage.dart';
import 'package:kaba_flutter/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:kaba_flutter/screens/home/me/personnal/PersonalPage.dart';
import 'package:kaba_flutter/screens/home/me/settings/SettingsPage.dart';
import 'package:kaba_flutter/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:kaba_flutter/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:kaba_flutter/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/screens/auth/recover/RecoverPasswordPage.dart';

var generalRoutes = {

  SplashPage.routeName: (BuildContext context) => SplashPage(),
  LoginPage.routeName : (BuildContext context) => LoginPage(),
  RegisterPage.routeName : (BuildContext context) => RegisterPage(),
  RecoverPasswordPage.routeName : (BuildContext context) => RecoverPasswordPage(),
  RetrievePasswordPage.routeName : (BuildContext context) => RetrievePasswordPage(),
  RestaurantDetailsPage.routeName : (BuildContext context) => RestaurantDetailsPage(),
  BestSellersPage.routeName : (BuildContext context) => BestSellersPage(),
  RestaurantMenuPage.routeName : (BuildContext context) => RestaurantMenuPage(),
  RestaurantFoodDetailsPage.routeName : (BuildContext context) => RestaurantFoodDetailsPage(),
  MyAddressesPage.routeName : (BuildContext context) => MyAddressesPage(),
  EditAddressPage.routeName : (BuildContext context) => EditAddressPage(),
  MyVouchersPage.routeName : (BuildContext context) => MyVouchersPage(),
  AddVouchersPage.routeName : (BuildContext context) => AddVouchersPage(),
  PersonalPage.routeName : (BuildContext context) => PersonalPage(),
  SettingsPage.routeName : (BuildContext context) => SettingsPage(),
  WebViewPage.routeName : (BuildContext context) => WebViewPage(),
  MySoldePage.routeName : (BuildContext context) => MySoldePage(),
  TransactionHistoryPage.routeName : (BuildContext context) => TransactionHistoryPage(),
//  PersonnalPage.routeName : (BuildContext context) => PersonnalPage(),
//  PersonnalPage.routeName : (BuildContext context) => PersonnalPage(),
//  PersonnalPage.routeName : (BuildContext context) => PersonnalPage(),


};