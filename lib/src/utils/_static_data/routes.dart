import 'package:KABA/src/NotificationTestPage.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/delete_account_questionning_contract.dart';
import 'package:KABA/src/contracts/delete_account_refund_contract.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantNewCommentWidget.dart';
import 'package:KABA/src/ui/screens/delete_account/DeleteAccountFixPropositionPage.dart';
import 'package:KABA/src/ui/screens/delete_account/DeleteAccountQuestioningPage.dart';
import 'package:KABA/src/ui/screens/home/_home/HomeWelcomeNewPage.dart';
import 'package:KABA/src/ui/screens/home/buy/search/SearchProductPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';

import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPageRefined.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/MeNewAccountPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopNewUpPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
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
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';

import '../../ui/screens/delete_account/DeleteAccountRefundQuestionnaryPage.dart';
import '../../ui/screens/delete_account/DeleteAccountSuccessfulPage.dart';
import '../../ui/screens/out_of_app_orders/fetching_package.dart';
import '../../ui/screens/out_of_app_orders/out_of_app.dart';
import '../../ui/screens/out_of_app_orders/shipping_package.dart';

var generalRoutes = {

  SplashPage.routeName: (BuildContext context) => SplashPage(),
  LoginPage.routeName : (BuildContext context) => LoginPage(),
  RegisterPage.routeName : (BuildContext context) => RegisterPage(),
  RecoverPasswordPage.routeName : (BuildContext context) => RecoverPasswordPage(),
  RetrievePasswordPage.routeName : (BuildContext context) => RetrievePasswordPage(),
  RestaurantDetailsPage.routeName : (BuildContext context) => RestaurantDetailsPage(presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
  ShopDetailsPage.routeName : (BuildContext context) => ShopDetailsPage(presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
  BestSellersPage.routeName : (BuildContext context) => BestSellersPage(presenter: BestSellerPresenter(BestSellerView())),
  RestaurantMenuPage.routeName : (BuildContext context) => RestaurantMenuPage(fromNotification: true, presenter: MenuPresenter(MenuView())),
  MyAddressesPage.routeName : (BuildContext context) => MyAddressesPage(presenter: AddressPresenter(AddressView())),
  EditAddressPage.routeName : (BuildContext context) => EditAddressPage(presenter: EditAddressPresenter(EditAddressView())),
  MyVouchersPage.routeName : (BuildContext context) => MyVouchersPage(),
  AddVouchersPage.routeName : (BuildContext context) => AddVouchersPage(),
  Personal2Page.routeName : (BuildContext context) => Personal2Page(presenter: PersonnalPagePresenter(PersonnalPageView())),
  SettingsPage.routeName : (BuildContext context) => SettingsPage(),
  MySoldePage.routeName : (BuildContext context) => MySoldePage(),
//  QrCodeScannerPage.routeName : (BuildContext context) => QrCodeScannerPage(),
  TransactionHistoryPage.routeName : (BuildContext context) => TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())),
  RestaurantFoodDetailsPage.routeName : (BuildContext context) => RestaurantFoodDetailsPage(presenter: FoodPresenter(FoodView())),
  FeedsPage.routeName : (BuildContext context) => FeedsPage(presenter: FeedPresenter(FeedView())),
  // OrderDetailsPage.routeName : (BuildContext context) => OrderDetailsPage(presenter: OrderDetailsPresenter()),
  // TopUpPage.routeName : (BuildContext context) => TopUpPage(presenter: TopUpPresenter()),
  SettingsPage.routeName : (BuildContext context) => SettingsPage(),
  InfoPage.routeName : (BuildContext context) => InfoPage(),
  CustomerCareChatPage.routeName : (BuildContext context) => CustomerCareChatPage(presenter: CustomerCareChatPresenter(CustomerCareChatView())),

//  NotificationTestPage.routeName : (BuildContext context) => NotificationTestPage(),
  ShopDetailsPage.routeName : (BuildContext context) => ShopDetailsPage(presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
  ShopListPageRefined.routeName : (BuildContext context) => ShopListPageRefined(restaurantListPresenter: RestaurantListPresenter(RestaurantListView()), foodProposalPresenter: RestaurantFoodProposalPresenter(RestaurantFoodProposalView())),
  ShopFlowerDetailsPage.routeName : (BuildContext context) => ShopFlowerDetailsPage(presenter: FoodPresenter(FoodView()),),
  OrderNewDetailsPage.routeName : (BuildContext context) => OrderNewDetailsPage(presenter: OrderDetailsPresenter(OrderDetailsView()),),
  HomeWelcomeNewPage.routeName : (BuildContext context) => HomeWelcomeNewPage(presenter: HomeWelcomePresenter(HomeWelcomeView()),),
  MeNewAccountPage.routeName : (BuildContext context) => MeNewAccountPage(),

  SearchProductPage.routeName : (BuildContext context) => SearchProductPage(),
  TopNewUpPage.routeName : (BuildContext context) => TopNewUpPage(presenter: TopUpPresenter(TopUpView())),
  MeNewAccountPage.routeName : (BuildContext context) => MeNewAccountPage(),
  OrderNewDetailsPage.routeName : (BuildContext context) => OrderNewDetailsPage(presenter: OrderDetailsPresenter(OrderDetailsView())),
  HomeWelcomeNewPage.routeName : (BuildContext context) => HomeWelcomeNewPage(presenter: HomeWelcomePresenter(HomeWelcomeView())),


  DeleteAccountRefundQuestionnaryPage.routeName : (BuildContext context) => DeleteAccountRefundQuestionnaryPage(presenter: DeleteAccountRefundPresenter(DeleteAccountRefundView()), fixId: null, ),
  DeleteAccountQuestioningPage.routeName : (BuildContext context) => DeleteAccountQuestioningPage(presenter:DeleteAccountQuestioningPresenter(DeleteAccountQuestioningView()) ),
  DeleteAccountSuccessfulPage.routeName : (BuildContext context) => DeleteAccountSuccessfulPage( ),
  DeleteAccountFixPropositionPage.routeName : (BuildContext context) => DeleteAccountFixPropositionPage( ),
  ShippingPackageOrderPage.routeName : (BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ShippingPackageOrderPage(
      additional_info: args == null ? '' : args['additional_info'] ?? '',
      additionnal_info_image: args == null ? null : args['additionnal_info_image'] ?? null,
      districts: args == null ? [] : args['districts'] ?? [],
    );
  },
    FecthingPackageOrderPage.routeName : (BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return FecthingPackageOrderPage(
      additional_info: args == null ? '' : args['additional_info'] ?? '',
      additionnal_info_image: args == null ? null : args['additionnal_info_image'] ?? null,
      districts: args == null ? [] : args['districts'] ?? [],

    );
  },
  OutOfAppOrderPage.routeName : (BuildContext context) =>OutOfAppOrderPage(),

};