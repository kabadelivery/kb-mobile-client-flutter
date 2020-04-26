import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';


class RecoverPasswordPage extends StatefulWidget {

  static var routeName = "/RecoverPasswordPage";

  CustomerModel customer;

  RecoverPasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    CustomerUtils.getCustomer().then((customer){
      widget.customer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("RECOVER PASSWORD", style:TextStyle(color:KColors.primaryColor)),
          leading: IconButton(icon: Icon(Icons.close, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 100),
                  Text('RECOVER PASSWORD', style:TextStyle(color:KColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 100),
                  SizedBox(width: 250,
                      child: Container(
                          padding: EdgeInsets.all(14),
                          child: TextField(decoration: InputDecoration.collapsed(hintText: "Identifier"), maxLength: 8, keyboardType: TextInputType.number, style: TextStyle(color:KColors.primaryColor)),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200))),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Text("RECOVER", style: TextStyle(fontSize: 14, color: Colors.white), ), onPressed: () {}),
                      ]),
                ]
            ),
          ),
        ));
  }

  void _moveToRegisterPage() {
    Navigator.of(context).pushNamed(RegisterPage.routeName);
  }
}
