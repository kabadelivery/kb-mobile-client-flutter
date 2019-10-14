import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


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
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Preferences", style:TextStyle(color:KColors.primaryColor))),
      body: Container(
          child:Container(
            child: Column(
                children: <Widget>[
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.security, color: KColors.primaryColor), onPressed: null),title: Text("Change Account Password", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.assignment, color: KColors.primaryColor), onPressed: null),title: Text("Terms and Conditions", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child: ListTile(leading: IconButton(icon: Icon(Icons.apps, color: KColors.primaryColor), onPressed: null),title: Text("App Info", style: TextStyle(color: Colors.black,fontSize: 16)))),
                  SizedBox(height: 2),
                  Container(color: Colors.white,child:ListTile(leading: IconButton(icon: Icon(Icons.question_answer, color: KColors.primaryColor), onPressed: null),title: Text("FAQ", style: TextStyle(color: Colors.black,fontSize: 16))))
                ]),
          )),
    );
  }
}
