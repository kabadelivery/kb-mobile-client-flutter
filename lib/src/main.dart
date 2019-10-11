import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaba_flutter/src/contracts/register_contract.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:kaba_flutter/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/vouchers/QrCodeScanner.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/DailyOrdersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contracts/login_contract.dart';
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
      home: SplashPage(),
//     home: RetrievePasswordPage(),
      routes: generalRoutes,
    );
  }
}

