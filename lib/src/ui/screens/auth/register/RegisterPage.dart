import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


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

  List<TextInputType> _loginFieldInputType = [TextInputType.emailAddress, TextInputType.emailAddress];

  List<int> _loginMaxLength = [8, 100];

  TextEditingController _loginFieldController = new TextEditingController();
  TextEditingController _codeFieldController = new TextEditingController();

  bool isCodeSent = false;
  bool isLoginError = false;
  bool isEmailError = false;
  bool isCodeError = false;

  /* circle loading progressing */
  bool isCodeSending = false;
  bool isAccountCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("REGISTER", style:TextStyle(color:KColors.primaryColor)),
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
        ),
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child:Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Text("CREATE ACCOUNT", style:TextStyle(color:KColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    /* radiobutton - check who are you */
                    !isCodeSent ? Row(
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
                        ]) : Container(),
                    SizedBox(height: 10),
                    Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(recoverModeHints[_registerModeRadioValue], textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),
                    SizedBox(height: 10),
                    SizedBox(width: 250,
                        child: Container(
                            padding: EdgeInsets.all(14),
                            child: TextField(controller: _loginFieldController, onChanged: _onLoginFieldTextChanged, maxLength: _loginMaxLength[_registerModeRadioValue],decoration: InputDecoration.collapsed(hintText: _loginFieldHint[_registerModeRadioValue]), style: TextStyle(color:KColors.primaryColor),  keyboardType: _loginFieldInputType[_registerModeRadioValue],),
                            decoration: isLoginError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),   border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                        )),
                    SizedBox(height: 30),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          isCodeSent ?
                          SizedBox(width: 80,
                              child: Container(
                                  padding: EdgeInsets.all(14),
                                  child: TextField(controller: _codeFieldController, maxLength: 4,decoration: InputDecoration.collapsed(hintText: "CODE"), style: TextStyle(color:KColors.primaryColor), keyboardType: TextInputType.number),
//                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200)
                                  decoration: isCodeError ?  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.red), color:Colors.grey.shade200) : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))
                          ) : Container(),
                          isCodeSent ? SizedBox(width:20) : Container(),
                         OutlineButton(
                              borderSide: BorderSide(
                                color: KColors.primaryColor, //Color of the border
                                style: BorderStyle.solid, //Style of the border
                                width: 0.8, //width of the border
                              ),
                              padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:Colors.white,child: Column(
                            children: <Widget>[
                              Text("CODE" /* if is code count, we should we can launch a discount */, style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                              /* stream builder, that shows that the code is been sent */
                              StreamBuilder<int>(
                                  stream: userDataBloc.sendRegisterCodeGetter,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      int error  = snapshot.data;
                                      switch(error) {
                                        case 0:
                                          /* means message sent ! */
//                                          setState(() {
                                            isCodeSent = true;
//                                          });
                                          break;
                                        case -1:
                                        /* account exists already */
                                       mToast("This account already exists ! ");
                                          break;
                                        case 500:
                                          /* means code already sent... wait and send later. */
//                                          setState(() {
                                            isCodeSent = true;
//                                          });
                                          break;
                                      }
                                      isCodeSending = false;
                                    }
                                    return isCodeSending ? CircularProgressIndicator() : Container();
                                  }
                              )
                            ],
                          ), onPressed: () {_sendCodeAction();}),
                        ]),
                    SizedBox(height: 30),
                    isCodeSent ? MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Text("REGISTER", style: TextStyle(fontSize: 14, color: Colors.white)), onPressed: () {}) : Container(),
                  ]
              ),
            ),
          ),
        ));
  }

  void _handleRadioValueChange (int value) {
    setState(() {
      /* clean the content */
      this._registerModeRadioValue = value;
      this._loginFieldController.text = "";
      this._codeFieldController.text = "";
    });
  }

  void _sendCodeAction() {
    String login = _loginFieldController.text;
    /* check the fields */
    if (_registerModeRadioValue == 0) {
      /* phone number */
      String phoneNumber = login;
      if (!Utils.isPhoneNumber_TGO(phoneNumber)) {
        setState(() {
          isLoginError = true;
        });
        return;
      }
    } else {
      /* email */
      String email = login;
      if (!Utils.isEmailValid(email)) {
        setState(() {
          isLoginError = true;
        });
        return;
      }
    }

    setState(() {
      isCodeSending = true;
    });

    /* send request, to the server, and if ok, save request params and update fields. */
    userDataBloc.sendRegisterCode(login: login);
    /* _save request params */
    _saveRequestParams();
  }

  _saveRequestParams () async {

    /* check the content */
    /* save type of request */
    /* save login */
    /* save start-time */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('register_type', _registerModeRadioValue);
    await prefs.setString('register_login', _loginFieldController.text);
    await prefs.setInt('register_last_action_time', DateTime.now().millisecond);
  }

  _retrieveRequestParams () {

    /* get type of request saved */
    /* get login */
    /* get start-time */
  }


  static void _loginFieldListener() {

  }

  void _onLoginFieldTextChanged(String value) {
    setState(() {
      isLoginError = false;
    });
  }

  void mToast(String message) { Toast.show(message, context);}
}
