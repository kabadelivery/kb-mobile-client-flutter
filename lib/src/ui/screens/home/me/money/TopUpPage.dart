import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class TopUpPage extends StatefulWidget {

  static var routeName = "/TopUpPage";

  TopUpPresenter presenter;

  var feesPercentage = 10;
  var total = 0;
  var fees = 0;

  TopUpPage({Key key, this.presenter}) : super(key: key);


  CustomerModel customer;

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> implements TopUpView {


  TextEditingController _phoneNumberFieldController;
  TextEditingController _amountFieldController;

  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  String feesDescription = "Fees allow us to support the transactions cost with T-money and Flooz";

  bool isGetFeesLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.topUpView = this;
    _phoneNumberFieldController = new TextEditingController();
    _phoneNumberFieldController.addListener(_checkOperator);
    _amountFieldController = new TextEditingController();
    _amountFieldController.addListener(_updateFees);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.fetchFees(widget.customer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
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
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    Expanded(flex: 4, child: Center(child: Text("Phone Number", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),))),
                    Expanded(flex: 6, child: TextField(controller: _phoneNumberFieldController,maxLength: 8, textAlign: TextAlign.center, style: TextStyle(fontSize: 18,color: KColors.primaryColor),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "90XXXX90"
                        )),
                    )
                  ]),
                ),
              ),

              SizedBox(height: 10),

              Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KColors.primaryColor),
                margin: EdgeInsets.only(left:15, right: 15),
                padding: EdgeInsets.only(top:20,bottom:20, left:15, right: 15),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                  Expanded(flex: 5, child: Text("Operator", textAlign: TextAlign.start, style: TextStyle(color: Colors.white))),
                  Expanded(flex: 5, child: Text("${operator}", textAlign: TextAlign.end, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))
                ]),
              ),

              SizedBox(height: 20),

              Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KColors.white),
                  margin: EdgeInsets.only(left:15, right: 15),
                  padding: EdgeInsets.only(top:5,bottom:5, left:5, right: 5),
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      Expanded(flex: 4, child: Container(child: Center(child: Text("AMOUNT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)))),
                      Expanded(flex: 6, child: Container(
                        child: TextField(controller: _amountFieldController, textAlign: TextAlign.center, maxLength: 6, style: TextStyle(color: KColors.primaryColor, fontSize: 30),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "3000",
                              border: InputBorder.none,
                            )),
                      ),
                      )
                    ]),
                  )),


              SizedBox(height: 10),

              Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(feesDescription, textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),

              SizedBox(height: 10),

              isGetFeesLoading ? Center(child: Container(padding: EdgeInsets.all(10), child: CircularProgressIndicator())) : Container(
                margin: EdgeInsets.only(top:10),
                padding: EdgeInsets.only(top:15,bottom:15, left:15, right: 15),
                color: Colors.white,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                  Expanded(flex: 4, child: Text("Fees (${widget.feesPercentage}%)", textAlign: TextAlign.start, style: TextStyle(fontSize: 15))),
                  Expanded(flex: 6, child: Text("${widget.fees} F", textAlign: TextAlign.end, style: TextStyle(fontSize: 15,color: Colors.green, fontWeight: FontWeight.bold
                  )))
                ]),
              ),

              SizedBox(height: 10),

              Container(
                margin: EdgeInsets.only(top:10),
                padding: EdgeInsets.only(top:15,bottom:15, left:15, right: 15),
                color: Colors.white,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                  Expanded(flex: 4, child: Text("Total", textAlign: TextAlign.start, style: TextStyle(fontSize: 15))),
                  Expanded(flex: 6, child: Text("${widget.total} F", textAlign: TextAlign.end, style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: KColors.primaryColor))),
                ]),
              ),

              SizedBox(height: 50),

              Row(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                      children: <Widget>[
                        Text("TOP UP", style: TextStyle(fontSize: 14, color: Colors.white)),
                        SizedBox(width: 8),
                        Text("${_getTotal()}F", style: TextStyle(fontSize: 24, color: Colors.yellow)),
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
                  ),
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

    Navigator.of(context).pop({'check_balance': true, 'link': link});
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: "PAYGATE - ${operator}",link: link),
      ),
    );*/
  }

  bool _checkOperator() {

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
      setState(() {
        this.operator = mOperator;
        isOperatorOk = true;
      });
    } else {
      setState(() {
        this.operator = mOperator;
        isOperatorOk = false;
      });
    }

    return isOperatorOk;
  }

  void iLaunchTransaction() {

    if (isGetFeesLoading){
      mToast("Please wait until we update fees percentage.");
      return;
    }

    if (!_checkOperator()) {
      mToast("Phone number is wrong");
    } else {
      if (widget.customer != null)
        widget.presenter.launchTopUp(
            widget.customer, "${_phoneNumberFieldController.text}",
            "${_amountFieldController.text}", widget.feesPercentage);
      else
        mToast("System error. Please wait a bit and start again.");
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _getFees() {
    String amount = _amountFieldController.text;
    int amount_;
    if(amount == null || "" == amount.trim())
      amount_ = 0;
    else
      amount_ = int.parse(amount);
    return (widget.feesPercentage.toDouble()*amount_.toDouble()/100).toInt();
  }

  _getTotal() {
    String amount = _amountFieldController.text;
    int amount_;
    if(amount == null || "" == amount.trim())
      amount_ = 0;
    else
      amount_ = int.parse(amount);
    return amount_+_getFees();
  }

  void _updateFees() {
    setState(() {
      widget.fees = _getFees();
      widget.total = _getTotal();
    });
  }

  @override
  void updateFees(int feesPercentage) {
    setState(() {
      widget.feesPercentage = feesPercentage;
    });
  }

  @override
  void showGetFeesLoading(bool isGetFeesLoading) {
     setState(() {
       this.isGetFeesLoading = isGetFeesLoading;
     });
  }
}
