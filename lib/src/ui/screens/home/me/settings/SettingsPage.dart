import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  static var routeName = "/SettingsPage";

  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('settings')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Container(
          child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
            color: KColors.new_gray, borderRadius: BorderRadius.circular(10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          InkWell(
            onTap: () => _jumpToRecoverPage(),
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(width: 0.8, color: Colors.grey.withAlpha(35)),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Icon(Icons.password, color: KColors.mBlue),
                SizedBox(
                  width: 10,
                ),
                Text(
                    Utils.capitalize(
                        "${AppLocalizations.of(context).translate('change_password')}"),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              ]),
            ),
          ),
          InkWell(
            onTap: () => _jumpWebPage("CGU", ServerRoutes.CGU_PAGE),
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(width: 0.8, color: Colors.grey.withAlpha(35)),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Icon(Icons.abc_outlined, color: KColors.primaryColor),
                SizedBox(
                  width: 10,
                ),
                Text(
                    Utils.capitalize(
                        "${AppLocalizations.of(context).translate('cgu')}"),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              ]),
            ),
          ),
          InkWell(
            onTap: () => _jumpToInfoPage(),
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(width: 0.8, color: Colors.grey.withAlpha(35)),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Icon(Icons.format_align_justify_outlined,
                    color: CommandStateColor.delivered),
                SizedBox(
                  width: 10,
                ),
                Text(
                    Utils.capitalize(
                        "${AppLocalizations.of(context).translate('app_info')}"),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              ]),
            ),
          ),
          InkWell(
            onTap: () => _jumpWebPage("FAQ", ServerRoutes.FAQ_PAGE),
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Icon(Icons.question_mark_rounded,
                    color: KColors.primaryYellowColor),
                SizedBox(
                  width: 10,
                ),
                Text(
                    Utils.capitalize(
                        "${AppLocalizations.of(context).translate('faq')}"),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              ]),
            ),
          ),
        ]),
      )),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _jumpWebPage(String title, String link) {
    _launchURL(link);

    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title,link: link),
      ),
    );*/
  }

  void _jumpToInfoPage() {
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(),
      ),
    );*/
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => InfoPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }

  _jumpToRecoverPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage(
            presenter: RecoverPasswordPresenter(), is_a_process: true),
      ),
    );
  }
}
