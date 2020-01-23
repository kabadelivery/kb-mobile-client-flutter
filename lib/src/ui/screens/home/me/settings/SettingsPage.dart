import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerConfig.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';


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
          backgroundColor: Colors.white, title: Text("Preferences", style:TextStyle(color:KColors.primaryColor))),
      body: Container(
          child:Container(
            child: Column(
                children: <Widget>[
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.security, color: KColors.primaryColor), onPressed: null),title: Text("Change Account Password", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.assignment, color: KColors.primaryColor), onPressed: null), onTap: ()=>_jumpWebPage("CGU", ServerRoutes.CGU_PAGE), title: Text("Terms and Conditions", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.apps, color: KColors.primaryColor), onPressed: null),title: Text("App Info", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child:ListTile(leading: IconButton(icon: Icon(Icons.question_answer, color: KColors.primaryColor), onPressed: null), onTap: ()=> _jumpWebPage("FAQ", ServerRoutes.FAQ_PAGE) ,title: Text("FAQ", style: TextStyle(color: Colors.black,fontSize: 16))))
                ]),
          )),
    );
  }

 void  _jumpWebPage(String title, String link) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title,link: link),
      ),
    );
  }
}
