import 'package:KABA/src/NotificationTestPage.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/feeds_contract.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/personal_page_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/feeds/FeedsPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/MySoldePage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/personnal/Personal2Page.dart';
import 'package:KABA/src/ui/screens/home/me/settings/SettingsPage.dart';
import 'package:KABA/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/QrCodeScanner.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';

var generalRoutes = {

  SplashPage.routeName: (BuildContext context) => SplashPage(),
  LoginPage.routeName : (BuildContext context) => LoginPage(),
  RegisterPage.routeName : (BuildContext context) => RegisterPage(),
  RecoverPasswordPage.routeName : (BuildContext context) => RecoverPasswordPage(),
  RetrievePasswordPage.routeName : (BuildContext context) => RetrievePasswordPage(),
  RestaurantDetailsPage.routeName : (BuildContext context) => RestaurantDetailsPage(presenter: RestaurantDetailsPresenter()),
  BestSellersPage.routeName : (BuildContext context) => BestSellersPage(presenter: BestSellerPresenter()),
  RestaurantMenuPage.routeName : (BuildContext context) => RestaurantMenuPage(fromNotification: true, presenter: MenuPresenter()),
  MyAddressesPage.routeName : (BuildContext context) => MyAddressesPage(presenter: AddressPresenter()),
  EditAddressPage.routeName : (BuildContext context) => EditAddressPage(presenter: EditAddressPresenter()),
  MyVouchersPage.routeName : (BuildContext context) => MyVouchersPage(),
  AddVouchersPage.routeName : (BuildContext context) => AddVouchersPage(),
  Personal2Page.routeName : (BuildContext context) => Personal2Page(presenter: PersonnalPagePresenter()),
  SettingsPage.routeName : (BuildContext context) => SettingsPage(),
  WebViewPage.routeName : (BuildContext context) => WebViewPage(),
  MySoldePage.routeName : (BuildContext context) => MySoldePage(),
  QrCodeScannerPage.routeName : (BuildContext context) => QrCodeScannerPage(),
  TransactionHistoryPage.routeName : (BuildContext context) => TransactionHistoryPage(presenter: TransactionPresenter()),
  RestaurantFoodDetailsPage.routeName : (BuildContext context) => RestaurantFoodDetailsPage(presenter: FoodPresenter()),
  FeedsPage.routeName : (BuildContext context) => FeedsPage(presenter: FeedPresenter()),
  WebViewPage.routeName : (BuildContext context) => WebViewPage(),
  OrderDetailsPage.routeName : (BuildContext context) => OrderDetailsPage(presenter: OrderDetailsPresenter()),
  TopUpPage.routeName : (BuildContext context) => TopUpPage(presenter: TopUpPresenter()),
  SettingsPage.routeName : (BuildContext context) => SettingsPage(),
  InfoPage.routeName : (BuildContext context) => InfoPage(),
  CustomerCareChatPage.routeName : (BuildContext context) => CustomerCareChatPage(presenter: CustomerCareChatPresenter()),

//  NotificationTestPage.routeName : (BuildContext context) => NotificationTestPage(),

};