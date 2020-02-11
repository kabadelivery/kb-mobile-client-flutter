import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaba_flutter/src/contracts/bestseller_contract.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/contracts/order_contract.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage2.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/HomeWelcomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/MeAccountPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/routes.dart';

import 'locale/locale.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        KabaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr'), // French
        const Locale('en'), // English
        const Locale('zh'), // Chinese
//        const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
      onGenerateTitle: (BuildContext context) =>
      "KABA",
      theme: ThemeData(primarySwatch: KColors.colorCustom),
//      home: MyOrderWidget(command: CommandModel.fake()),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
//      home: HomeWelcomePage(presenter: HomeWelcomePresenter()),
    home: SplashPage(),
   //      home: BestSellersPage(presenter: BestSellerPresenter(),),
      routes: generalRoutes,
    );
  }
}
