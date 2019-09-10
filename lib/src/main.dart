import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/DailyOrdersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderDetailsPage.dart';
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
//      KabaLocalizations.of(context).app_name.toString(),
      "KABA",
      theme: ThemeData(primarySwatch: KColors.colorCustom),
//      home: MyOrderWidget(command: CommandModel.fake()),
      home: OrderDetailsPage(),
      routes: generalRoutes,
    );
  }
}

