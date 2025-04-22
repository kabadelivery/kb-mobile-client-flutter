import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/transfer_money_amount_confirmation_contract.dart';
import 'package:KABA/src/contracts/transfer_money_request_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransferMoneyAmountConfirmationPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

class TransferMoneyRequestPage extends StatefulWidget {
  static var routeName = "/TransferMoneyRequest";

  TransferMoneyRequestPresenter presenter;

  TransferMoneyRequestPage({Key key, this.title, this.presenter})
      : super(key: key);

  final String title;

  CustomerModel customer;

  @override
  _TransferMoneyRequestPageState createState() =>
      _TransferMoneyRequestPageState();
}

class _TransferMoneyRequestPageState extends State<TransferMoneyRequestPage>
    implements TransferMoneyRequestView {
  TextEditingController _phoneNumberFieldController;

  bool isOperatorOk = false;

  var isLaunching = false;

  var isTgoNumber = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.transferMoneyRequestView = this;
    _phoneNumberFieldController = TextEditingController();
    /* _phoneNumberFieldController.addListener((){
      setState(() {
        isTgoNumber = Utils.isPhoneNumber_TGO(_phoneNumberFieldController.text);
      });
    });*/
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('transfer')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.translate('account')}",
                          children: [
                            TextSpan(
                                text: " *",
                                style: TextStyle(color: KColors.primaryColor))
                          ],
                          style: TextStyle(fontSize: 12, color: Colors.grey))),
                  SizedBox(height: 5),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                color: KColors.new_gray,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: TextField(
                                controller: _phoneNumberFieldController,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                    fillColor: Colors.yellow,
                                    border: InputBorder.none,
                                    hintMaxLines: 5,
                                    hintStyle: TextStyle(fontSize: 13)),
                                keyboardType: TextInputType.number),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
          ),

//              "Phone Number",
          SizedBox(height: 10),

          Container(
            child: Text(
                "${AppLocalizations.of(context)!.translate('real_time_transfer_no_refunded')}",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          ),

          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              iLaunchTransaction();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            "${AppLocalizations.of(context)!.translate('next')}"
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        isLaunching
                            ? Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                      height: 20,
                                      width: 20),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
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
//    if (Utils.isPhoneNumber_TGO(phoneNumber)) {
    // can launch
    if (widget.customer != null) {
      if (widget.customer.phone_number != phoneNumber &&
          widget.customer.email != phoneNumber)
        widget.presenter
            .launchTransferMoneyRequest(widget.customer, phoneNumber);
      else
        _showDialog(
            message:
                "${AppLocalizations.of(context)!.translate('cant_transfer_own_account')}",
            icon: Icon(FontAwesomeIcons.user, color: KColors.primaryColor));
    } else
      mToast("${AppLocalizations.of(context)!.translate('system_error')}");
    /* } else {
      // can't launch
      mToast("${AppLocalizations.of(context)!.translate('phone_number_wrong')}");
    }*/
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  Future<void> continueTransaction(CustomerModel customer) async {
    showLoading(false);
    if (customer == null) {
      _showDialog(
          message:
              "${AppLocalizations.of(context)!.translate('user_no_exists_in_db')}",
          icon: Icon(FontAwesomeIcons.user, color: Colors.grey));
    } else {
      /* jump to next activity with this information */
      Navigator.pop(context);
      Navigator.of(context)
          .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
        return TransferMoneyAmountConfirmationPage(
            moneyReceiver: customer,
            presenter: TransferMoneyAmountConfirmationPresenter());
      }));
    }
  }

  void _showDialog({var icon, var message}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              /* icon */
              SizedBox(
                height: 120,
                width: 120,
                child: icon,
              ),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: <Widget>[
              //
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('ok')}",
                    style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }
}
