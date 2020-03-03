import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';


class TransferMoneyRequestPage extends StatefulWidget {

  static var routeName = "/TransferMoneyRequest";

  TransferMoneyRequestPresenter presenter;

  TransferMoneyRequestPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  CustomerModel customer;

  @override
  _TransferMoneyRequestPageState createState() => _TransferMoneyRequestPageState();
}

class _TransferMoneyRequestPageState extends State<TransferMoneyRequestPage> implements TransferMoneyRequestView {


  TextEditingController _phoneNumberFieldController;

//  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.transferMoneyRequestView = this;
//    _phoneNumberFieldController = new TextEditingController();
//    _phoneNumberFieldController.addListener(_checkOperator);
//    _amountFieldController = new TextEditingController();

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
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
        title: Text("TRANSFER", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              SizedBox(height:20),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:10,bottom:10, left:20, right: 20),
                child: Row(children: <Widget>[
                  Text("Account"),
                  SizedBox(width:20),
                  Expanded(flex: 7, child:
                      TextField(controller: _phoneNumberFieldController, enabled: !isLaunching,
                      decoration: InputDecoration(labelText: "Phone Number", /* if  already sat, we cant put nothing else */
                        border: InputBorder.none,
                      ))
                  ),
                ]),
              ),
//              "Phone Number",
              SizedBox(height: 10),

              Container(child:Text("Real time transfer can't be refunded.", textAlign: TextAlign.left, style: TextStyle(fontSize: 12, color: Colors.grey))),

              SizedBox(height: 10),


                  Container(margin: EdgeInsets.only(top:15, bottom:15, left:20, right:20),
                    child: SizedBox(
                      width: double.infinity,
                      child: MaterialButton(color: Utils.isPhoneNumber_TGO(_phoneNumberFieldController.text)? KColors.primaryColor : KColors.primaryColor.withAlpha(150),  padding: EdgeInsets.only(top:5, bottom:5),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("NEXT", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
                              isLaunching ?  Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 20, width: 20) ,
                                ],
                              )  : Container(),
                            ],
                          ), onPressed: () {
                            iLaunchTransaction();
                          }),
                    ),
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


  void iLaunchTransaction() {

    String phoneNumber = _phoneNumberFieldController.text;

    if (Utils.isPhoneNumber_TGO(phoneNumber)) {
      // can launch
      if (widget.customer != null)
        widget.presenter.launchTransferMoneyRequest(widget.customer, phoneNumber);
      else
        mToast("System error. Please wait a bit and start again.");
    } else {
      // can't launch
      mToast("Phone number is wrong");
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void continueTransaction(CustomerModel customer) {
    if (customer == null) {
      // user doenst exist
    } else {
      /* jump to next activity with this information */

    }
  }
}
