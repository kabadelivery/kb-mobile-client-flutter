import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/contracts/topup_contract.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';


class TopUpPage extends StatefulWidget {

  static var routeName = "/TopUpPage";

  TopUpPresenter presenter;

  TopUpPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> implements TopUpView {


  TextEditingController _phoneNumberFieldController;
  TextEditingController _amountFieldController;

  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  var customer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.topUpView = this;
    _phoneNumberFieldController = new TextEditingController();
    _phoneNumberFieldController.addListener(_checkOperator);
    _amountFieldController = new TextEditingController();

    CustomerUtils.getCustomer().then((customer) {
      this.customer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        title: Text("TOP UP", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:5,bottom:5, left:5, right: 5),
                child: Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                    Expanded(flex: 7, child: Center(child: Text("Phone Number", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),))),
                    Expanded(flex: 3, child: Center(
                      child: TextField(controller: _phoneNumberFieldController,maxLength: 8,style: TextStyle(color: KColors.primaryColor),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "90XXXX90"
                          )),
                    ))
                  ]),
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: EdgeInsets.only(top:10,bottom:10, left:5, right: 5),
                color: Colors.white,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                  Expanded(flex: 7, child: Center(child: Text("Operator"))),
                  Expanded(flex: 3, child: Center(child: Text("${operator}")))
                ]),
              ),

              SizedBox(height: 10),

              Container(
                  padding: EdgeInsets.only(top:5,bottom:5, left:5, right: 5),
                  color: Colors.white,
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
                      Expanded(flex: 7, child: Center(child: Text("Amount"))),
                      Expanded(flex: 3, child: Center(child: TextField(controller: _amountFieldController, maxLength: 6, style: TextStyle(color: KColors.primaryColor),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "2000",
                              border: InputBorder.none,
                            )),
                      ))
                    ]),
                  )),
              SizedBox(height: 50),

              Row(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                    children: <Widget>[
                      Text("LAUNCH", style: TextStyle(fontSize: 14, color: Colors.white)),
                      isLaunching ?  Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                        ],
                      )  : Container(),
                    ],
                  ), onPressed: () {
                    iLaunchTransaction();
                  }),
                ],
              ),
            ]
        ),
      ),
    );
  }

  @override
  void networkError() {
    showLoading(false);
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLaunching = isLoading;
    });
  }

  @override
  void systemError() {
    showLoading(false);
  }

  @override
  void topUpToWeb(String link) {

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: "PAYGATE - ${operator}",link: link),
      ),
    );
  }

  void _checkOperator() {

    String number = "${_phoneNumberFieldController.text}";

   String mOperator = "---";
    isOperatorOk = true;

    if (Utils.isPhoneNumber_TGO(number)) {
      if (Utils.isPhoneNumber_Moov(number)) {
        mOperator = "MOOV";
      } else if (Utils.isPhoneNumber_Tgcel(number)) {
        mOperator = "TOGOCEL";
      } else {
        mOperator = "---";
      }
    } else {
      setState(() {
        isOperatorOk = false;
      });
    }

    setState(() {
      this.operator = mOperator;
      isOperatorOk = true;
    });

  }

  void iLaunchTransaction() {

    if (!isOperatorOk)
      mToast("Phone number is wrong");
    else {
      if (customer != null)
        widget.presenter.launchTopUp(
            customer, "${_phoneNumberFieldController.text}",
            "${_amountFieldController.text}");
      else
        mToast("System error. Please wait a bit and start again.");
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }
}
