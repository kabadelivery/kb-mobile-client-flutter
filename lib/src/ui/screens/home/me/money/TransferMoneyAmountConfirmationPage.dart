import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/transfer_money_amount_confirmation_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import 'TransferMoneySuccessPage.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class TransferMoneyAmountConfirmationPage extends StatefulWidget {
  static var routeName = "/TransferMoneyAmountConfirmationPage";

  TransferMoneyAmountConfirmationPresenter presenter;

  CustomerModel mySelf;

  TransferMoneyAmountConfirmationPage(
      {Key key, this.title, this.moneyReceiver, this.presenter})
      : super(key: key);

  final String title;

  CustomerModel moneyReceiver;

  @override
  _TransferMoneyAmountConfirmationPageState createState() =>
      _TransferMoneyAmountConfirmationPageState();
}

class _TransferMoneyAmountConfirmationPageState
    extends State<TransferMoneyAmountConfirmationPage>
    implements TransferMoneyAmountConfirmationView {
  TextEditingController _amountFieldController;

  var isLaunching = false;
  bool _isAmountOk = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.transferMoneyAmountConfirmationView = this;
    _amountFieldController = new TextEditingController();
    _amountFieldController.addListener(() => isAmountOk());

    CustomerUtils.getCustomer().then((customer) {
      widget.mySelf = customer;
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
                    "${AppLocalizations.of(context)!.translate('top_kaba_account')}"),
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
          Center(
            child: Column(children: <Widget>[
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      border: new Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              widget?.moneyReceiver?.profile_picture))))),
              SizedBox(
                height: 20,
              ),
              Text(
                widget?.moneyReceiver?.nickname,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    color: KColors.new_black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                Utils.hidePhoneNumber(widget?.moneyReceiver?.phone_number),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal),
              ),
            ]),
          ),
          SizedBox(height: 30),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.translate('insert_transfer_amount')}",
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
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8))),
                            child: TextField(
                                controller: _amountFieldController,
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
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            child: Text(
                                "${AppLocalizations.of(context)!.translate('currency')}",
                                style: TextStyle(color: KColors.primaryColor)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                color: KColors.primaryColor.withAlpha(30)))
                      ],
                    ),
                  )
                ]),
          ),
          SizedBox(height: 20),
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
                            "${AppLocalizations.of(context)!.translate('to_transfer')}"
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

  Future<void> iLaunchTransaction() async {
    if (isLaunching) return;

    if (!_isAmountOk) {
      _showDialog(
          message:
              "${AppLocalizations.of(context)!.translate('amount_greater_than_0')}",
          icon:
              Icon(FontAwesomeIcons.exclamationTriangle, color: KColors.new_black));
      return;
    }

    // pick password
    var results = await Navigator.of(context)
        .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return RetrievePasswordPage(type: 2);
    }));
    // retrieve password then do it,
    if (results != null &&
        results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null ||
          results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context)!.translate('code_wrong')}");
      } else {
        String _mCode = results['code'];
        if (Utils.isCode(_mCode)) {
          String amount = _amountFieldController.text;
          if (widget.moneyReceiver != null && widget.mySelf != null)
            widget.presenter.launchTransferMoneyAction(
                widget.mySelf, widget.moneyReceiver.id, _mCode, amount);
        } else {
          mToast("${AppLocalizations.of(context)!.translate('code_wrong')}");
        }
      }
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void balanceInsufficient() {
    _showDialog(
        message:
            "${AppLocalizations.of(context)!.translate('balance_not_sufficient')}",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: KColors.new_black));
  }

  @override
  void passwordWrong() {
    _showDialog(
        message: "${AppLocalizations.of(context)!.translate('password_wrong_')}",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: KColors.new_black));
  }

  @override
  void transactionError(CustomerModel customer) {
    _showDialog(
        message:
            "${AppLocalizations.of(context)!.translate('transaction_error')}",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: KColors.new_black));
  }

  @override
  void transactionSuccessful(
      CustomerModel moneyReceiver, String amount, String balance) {
    // jump to success page
    StateContainer.of(context).updateBalance(balance: int.parse(balance));
    // give money
    Navigator.pop(context);

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TransferMoneySuccessPage(
                amount: amount, moneyReceiver: moneyReceiver),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));

    /*Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TransferMoneySuccessPage(amount: amount, moneyReceiver: moneyReceiver);
        }
    ));*/
  }

  void _showDialog({var icon, var message, bool isSuccess = false}) {
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
                  if (isSuccess) Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  Future<void> _playMusicForSuccess() async {
    // play music
    // AudioPlayer audioPlayer = AudioPlayer();
    final player = AudioPlayer();
    player.play(MusicData.money_transfer_successfull);
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500);
    }
  }

  isAmountOk() {
    // only ints
    String amount = _amountFieldController.text;
    final regex = RegExp(r'^[0-9]{2,5}$');
    bool res = regex.hasMatch(amount) && int.parse(amount) > 0;
    setState(() {
      _isAmountOk = res;
    });
  }
}
