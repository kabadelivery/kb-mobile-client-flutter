import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
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
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
          backgroundColor: Colors.white, brightness: Brightness.light, title: Text("${AppLocalizations.of(context).translate('settings')}", style:TextStyle(color:KColors.primaryColor))),
      body: Container(
          child:Container(
            child: Column(
                children: <Widget>[
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.security, color: KColors.primaryColor), onPressed: ()=>_jumpToRecoverPage()),  onTap: ()=>_jumpToRecoverPage(),title: Text("${AppLocalizations.of(context).translate('change_password')}", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.assignment, color: KColors.primaryColor), onPressed: ()=>_jumpWebPage("CGU", ServerRoutes.CGU_PAGE),), onTap: ()=>_jumpWebPage("${AppLocalizations.of(context).translate('cgu')}", ServerRoutes.CGU_PAGE), title: Text("${AppLocalizations.of(context).translate('terms_and_conditions')}", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.apps, color: KColors.primaryColor), onPressed: ()=> _jumpToInfoPage()), onTap: ()=> _jumpToInfoPage(), title: Text("${AppLocalizations.of(context).translate('app_info')}", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child:ListTile(leading: IconButton(icon: Icon(Icons.question_answer, color: KColors.primaryColor), onPressed:  ()=> _jumpWebPage("FAQ", ServerRoutes.FAQ_PAGE) ), onTap: ()=> _jumpWebPage("${AppLocalizations.of(context).translate('faq')}", ServerRoutes.FAQ_PAGE) ,title: Text("${AppLocalizations.of(context).translate('faq')}", style: TextStyle(color: Colors.black,fontSize: 16))))
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

  void  _jumpWebPage(String title, String link) {

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
    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
          InfoPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }

  _jumpToRecoverPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage(presenter: RecoverPasswordPresenter(), is_a_process: true),
      ),
    );
  }

}
