import 'package:flutter/material.dart';
import 'package:kaba_flutter/locale/locale.dart';
import 'package:kaba_flutter/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:kaba_flutter/screens/auth/register/RegisterPage.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/routes.dart';

class LoginPage extends StatefulWidget {

  static var routeName = "/LoginPage";

  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 100),
                  Text(KabaLocalizations.of(context).connexion.toUpperCase(), style:TextStyle(color:KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 100),
                  SizedBox(width: 250,
                      child: Container(
                          padding: EdgeInsets.all(14),
                          child: TextField(decoration: InputDecoration.collapsed(hintText: "Identifier"), style: TextStyle(color:KColors.primaryColor)),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Text(KabaLocalizations.of(context).connexion.toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white), ), onPressed: () {_launchConnexion();}),
                       SizedBox(width:20),
                        MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:KColors.primaryYellowColor,child: Text("REGISTER", style: TextStyle(fontSize: 14, color: Colors.white)), onPressed: () {_moveToRegisterPage();}),
                      ]),
                  SizedBox(height: 30),
                  GestureDetector(
                    child:Text("Recover Password?", style: KStyles.hintTextStyle_gray),
                    onTap: (){_moveToRecoverPasswordPage();},
                  )
                ]
            ),
          ),
        ));
  }

  void _moveToRegisterPage() {
    Navigator.of(context).pushNamed(RegisterPage.routeName);
  }

  void _moveToRecoverPasswordPage() {
    Navigator.of(context).pushNamed(RecoverPasswordPage.routeName);
  }

  void _launchConnexion() {
    /* jump to a page that just needs numbers from you. */

  }
}
