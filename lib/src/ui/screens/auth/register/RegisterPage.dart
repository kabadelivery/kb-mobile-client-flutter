import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class RegisterPage extends StatefulWidget {

  static var routeName = "/RegisterPage";

  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {


  int _registerModeRadioValue = 0;

  List<String> recoverModeHints = ["Insert the Phone number you are most likely to make T-MONEY or FLOOZ transactions with.\n\nOnly TOGOLESE phone numbers are allowed.",
    "Insert your E-mail address"];

  List<String> _loginFieldHint = ["90 XX XX XX", "xxxxxx@yyy.zzz"];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      title: Text("REGISTER", style:TextStyle(color:KColors.primaryColor)),
      leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 60),
                  Text("REGISTER", style:TextStyle(color:KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 40),
                  /* radiobutton - check who are you */
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _registerModeRadioValue,
                          onChanged: _handleRadioValueChange,
                        ), new Text(
                            'Phone',
                            style: new TextStyle(fontSize: 16.0)),
                        new Radio(
                          value: 1,
                          groupValue: _registerModeRadioValue,
                          onChanged: _handleRadioValueChange,
                        ), new Text(
                            'E-mail',
                            style: new TextStyle(fontSize: 16.0)),
                      ]),
                  SizedBox(height: 10),
                  Text(recoverModeHints[_registerModeRadioValue], textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray),
                  SizedBox(height: 10),
                  SizedBox(width: 250,
                      child: Container(
                          padding: EdgeInsets.all(14),
                          child: TextField(decoration: InputDecoration.collapsed(hintText: _loginFieldHint[_registerModeRadioValue]), style: TextStyle(color:KColors.primaryColor)),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                      SizedBox(width: 80,
                          child: Container(
                              padding: EdgeInsets.all(14),
                              child: TextField(decoration: InputDecoration.collapsed(hintText: "CODE"), style: TextStyle(color:KColors.primaryColor)),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))
                      ),
                        SizedBox(width:20),
                        OutlineButton(
                            borderSide: BorderSide(
                              color: KColors.primaryColor, //Color of the border
                              style: BorderStyle.solid, //Style of the border
                              width: 0.8, //width of the border
                            ),
                            padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:Colors.white,child: Text("CODE", style: TextStyle(fontSize: 14, color: KColors.primaryColor)), onPressed: () {_sendCodeAction();}),
                      ]),
                  SizedBox(height: 30),
                  MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Text("REGISTER", style: TextStyle(fontSize: 14, color: Colors.white)), onPressed: () {}),
                ]
            ),
          ),
        ));
  }

  void _handleRadioValueChange (int value) {
    setState(() {
      this._registerModeRadioValue = value;
    });
  }

  void _sendCodeAction() {}


}
