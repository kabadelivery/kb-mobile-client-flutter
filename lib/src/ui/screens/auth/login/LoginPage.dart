import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/contracts/register_contract.dart';
import 'package:kaba_flutter/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:kaba_flutter/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:kaba_flutter/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {

  static var routeName = "/LoginPage";

  LoginPresenter presenter;

  LoginPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginView {

  String hint = "Insert the Phone number or E-mail you used to create your KABA account";

  bool isConnecting = false;

  TextEditingController _loginFieldController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    this.widget.presenter.loginView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50),
                  Text("CONNEXION", style:TextStyle(color:KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 100),
                  SizedBox(height: 10),
                  Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(hint, textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                  SizedBox(height: 30),
                  SizedBox(width: 250,
                      child: Container(
                          padding: EdgeInsets.all(14),
                          child: TextField(controller: _loginFieldController, decoration: InputDecoration.collapsed(hintText: "Identifier"), style: TextStyle(color:KColors.primaryColor)),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                          children: <Widget>[
                            Text("CONNEXION", style: TextStyle(fontSize: 14, color: Colors.white)),
                            isConnecting ?  Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                              ],
                            )  : Container(),
                          ],
                        ), onPressed: () {_launchConnexion();}),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage (presenter: RegisterPresenter()),
      ),
    );
  }

  void _moveToRecoverPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage (),
      ),
    );
  }

  Future _launchConnexion() async {

   String login = _loginFieldController.text;

   // control login stuff
  if (!(Utils.isEmailValid(login) || Utils.isPhoneNumber_TGO(login))) {
    /* login error */
    mToast("Sorry, Login error");
    return;
  }

   // 1. get password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return RetrievePasswordPage(type: 0);
      }
    ));
    if (results != null && results.containsKey('code') && results.containsKey('type')) {
      String _mCode = results['code'];
//      int type = results['type'];
      showLoading(true);
      if (Utils.isCode(_mCode)) {
        this.widget.presenter.login(login, _mCode);
      }
    }
  }

  @override
  void loginFailure(String message) {
    showLoading(false);
  }

  @override
  void loginSuccess() {

    /* token must be saved by now. */

    showLoading(false);
    /* jump to home page. */
    mToast("Login Successfull");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage (),
      ),
    );
  }

  @override
  void showLoading(bool isLoading) {
    isConnecting = isLoading;
  }

  void mToast(String message) { Toast.show(message, context, duration: Toast.LENGTH_LONG);}


}
