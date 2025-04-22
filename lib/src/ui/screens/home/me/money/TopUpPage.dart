import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MRaisedButton.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toast/toast.dart';

class TopUpPage extends StatefulWidget {
  static var routeName = "/TopUpPage";

  TopUpPresenter? presenter;

  var total = 0;

  var fees = 0;

  double? fees_tmoney = 10.0;

  double? fees_flooz = 10.0;

  double? fees_bankcard = 10.0;

  TopUpPage({Key? key, this.presenter}) : super(key: key);

  CustomerModel? customer;

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> implements TopUpView {
  TextEditingController? _phoneNumberFieldController;
  TextEditingController? _amountFieldController;
  TextEditingController? _totalAmountFieldController;

  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  double euroRatio = 657.60;

  String feesDescription = "";
  bool isGetFeesLoading = false;
  FocusNode? _totalFocusNode, _amountFocusNode;

  int selectedPaymentMode = 0; // 0 tmoney 1 bank card 2 flooz

  TextEditingController? _feesFieldController;

  int BANK_MIN_AMOUNT = 10000;

  @override
  void initState() {
    super.initState();
    widget.presenter!.topUpView = this;
    _phoneNumberFieldController = new TextEditingController();
    _totalAmountFieldController = new TextEditingController();
    _amountFieldController = new TextEditingController();
    _feesFieldController = new TextEditingController();

    _phoneNumberFieldController!.addListener(_checkOperator);
    _amountFieldController!.addListener(_updateFromInitialAmountTotal);
    _totalAmountFieldController!.addListener(_updateFromTotal);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter!.fetchFees(widget.customer!);
//      widget.presenter.fetchTopUpConfiguration(widget.customer);
    });

    _totalFocusNode = new FocusNode();
    _amountFocusNode = new FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feesDescription =
        "${AppLocalizations.of(context)!.translate('why_top_up_fees')}";
  }

  void _updateSelectedPaymentMode(int mode) {
    selectedPaymentMode = mode;
    _updateFromInitialAmountTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
            "${AppLocalizations.of(context)!.translate('top_up')}".toUpperCase(),
            style: TextStyle(color: KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(height: 15),
          /* define mobile money and visa-card */
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () =>
                          setState(() => _updateSelectedPaymentMode(0)),
                      child: Container(
                          child: Text("T-MONEY",
                              style:
                                  TextStyle(color: KColors.new_black, fontSize: 16)),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: selectedPaymentMode == 0
                                  ? KColors.primaryColor.withAlpha(100)
                                  : Colors.grey.withAlpha(100),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))))),
                  InkWell(
                      onTap: () =>
                          setState(() => _updateSelectedPaymentMode(1)),
                      child: Container(
                          child: Text("BANK CARD",
                              style:
                                  TextStyle(color: KColors.new_black, fontSize: 16)),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: selectedPaymentMode == 1
                                  ? KColors.primaryColor.withAlpha(100)
                                  : Colors.grey.withAlpha(100),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))))),
                  InkWell(
                      onTap: () =>
                          setState(() => _updateSelectedPaymentMode(2)),
                      child: Container(
                          child: Text("FLOOZ",
                              style:
                                  TextStyle(color: KColors.new_black, fontSize: 16)),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: selectedPaymentMode == 2
                                  ? KColors.primaryColor.withAlpha(100)
                                  : Colors.grey.withAlpha(100),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)))))
                ]),
          ),
          selectedPaymentMode != 1
              ? Column(children: [
                  SizedBox(height: 30),
                  /* phone number just in case we are working with moov*/
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('topup_phone_number')}")),
                          Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(40),
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
                                    keyboardType: TextInputType.phone),
                              ))
                        ]),
                  ),
                ])
              : Container(),
          Column(children: [
            SizedBox(height: 30),
            /* amount you wanna get paid */
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                            "${AppLocalizations.of(context)!.translate('amount_to_topup')}")),
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(40),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
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
                        ))
                  ]),
            ),
          ]),
          SizedBox(height: 10),
          isGetFeesLoading
              ? SizedBox(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(KColors.mGreen)),
                  height: 15,
                  width: 15)
              : Container(),
          SizedBox(height: 5),

          /* please be patient ... */

          isGetFeesLoading
              ? Text(
                  "${"${AppLocalizations.of(context)!.translate('please_wait_fees_percentage')}"}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: KColors.mGreen, fontWeight: FontWeight.bold))
              : Text(
                  "* ${"${AppLocalizations.of(context)!.translate('top_up_fees_are')}"}"
                  " ${_getFees()}%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: KColors.primaryColor,
                      fontWeight: FontWeight.bold)),
          Column(children: [
            SizedBox(height: 10),
            /* amount you wanna get paid */
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                            "${AppLocalizations.of(context)!.translate('fees')}")),
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: KColors.primaryYellowColor.withAlpha(40),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: TextField(
                              controller: _feesFieldController,
                              enabled: false,
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  fillColor: Colors.yellow,
                                  border: InputBorder.none,
                                  hintMaxLines: 5,
                                  hintStyle: TextStyle(fontSize: 13)),
                              keyboardType: TextInputType.number),
                        ))
                  ]),
            ),
          ]),
          Column(children: [
            SizedBox(height: 10),
            /* amount you wanna get paid */
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                            "${AppLocalizations.of(context)!.translate('total_amount')}")),
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: CommandStateColor.delivered.withAlpha(40),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: TextField(
                              controller: _totalAmountFieldController,
                              enabled: false,
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  fillColor: Colors.yellow,
                                  border: InputBorder.none,
                                  hintMaxLines: 5,
                                  hintStyle: TextStyle(fontSize: 13)),
                              keyboardType: TextInputType.number),
                        ))
                  ]),
            ),
          ]),
          SizedBox(height: 30),
          Center(
              child: Text(
                  "${AppLocalizations.of(context)!.translate('total_amount')}: ${_getTotalAmountEuro()} €")),
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(60))),
                child: MRaisedButton(
                    padding: EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    color: KColors.primaryColor,
                    child: Row(
                      children: <Widget>[
                        Text(
                            "${AppLocalizations.of(context)!.translate('top_up')}"
                                .toUpperCase(),
                            style:
                                TextStyle(fontSize: 14, color: Colors.white)),
                        SizedBox(width: 10),
                        Text("${_totalAmountFieldController!.text} XOF",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(width: 8),
                        isLaunching
                            ? Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                      height: 15,
                                      width: 15),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                    onPressed: () {
                      iLaunchTransaction();
                    }),
              ),
            ],
          ),
          SizedBox(height: 50)
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

  @override
  void topUpToWeb(String link) {
    Navigator.of(context).pop({'check_balance': true, 'link': link});
  }

  @override
  void topUpToPush() {
    Navigator.of(context).pop({'check_balance': true});
  }

  bool _checkOperator() {
    String number = "${_phoneNumberFieldController!.text}";

    String mOperator = "---";
    isOperatorOk = true;

    if (Utils.isPhoneNumber_TGO(number)) {
      if (Utils.isPhoneNumber_Moov(number)) {
        mOperator = "MOOV";
        setState(() {
          selectedPaymentMode = 2;
        });
      } else if (Utils.isPhoneNumber_Tgcel(number)) {
        mOperator = "TOGOCEL";
        setState(() {
          selectedPaymentMode = 0;
        });
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
    if (isGetFeesLoading) {
      mToast(
          "${AppLocalizations.of(context)!.translate('please_wait_fees_percentage')}");
      return;
    }

    if (selectedPaymentMode != 1 &&
        !Utils.isPhoneNumber_TGO(_phoneNumberFieldController!.text)) {
      mToast("${AppLocalizations.of(context)!.translate('phone_number_wrong')}");
    } else {
      if (widget.customer != null) if (selectedPaymentMode == 0 ||
          selectedPaymentMode == 2)
        widget.presenter!.launchTopUp(
            widget.customer!,
            "${_phoneNumberFieldController!.text}",
            "${_amountFieldController!.text}",
            _getFees());
      else {
        // launch pay dunya
        String amount = "${_amountFieldController!.text}";
        int _amount = int.parse(amount);
        if (_amount >= BANK_MIN_AMOUNT)
          widget.presenter!.launchPayDunya(
              widget.customer!, "${_amountFieldController!.text}", _getFees());
        else
          mDialog(
              "${AppLocalizations.of(context)!.translate('bank_card_top_up_min')} ${BANK_MIN_AMOUNT}");
      }
      else
        mToast("${AppLocalizations.of(context)!.translate('system_error')}");
    }
  }

  void mToast(String message) {
    Toast.show(message, duration: Toast.lengthLong);
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String? svgIcons,
      Icon? icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function? actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons!,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes!();
                      },
                    ),
                  ]
                : <Widget>[
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

  void _updateFromTotal() {
    /* check which one has focus before updating */
    setState(() {
      if (!_amountFocusNode!.hasFocus) {
        // update fees
        xrint("amount field doesnt have focus ");
        _amountFieldController!.removeListener(_updateFromInitialAmountTotal);
        _amountFieldController!.text = "${_getRealInitialAmountFromTotal()}";
        _amountFieldController!.addListener(_updateFromInitialAmountTotal);
        widget.fees = _getFeesFromTotal();
        _feesFieldController!.text = "${widget.fees}";
        // update amount
      } else {
        xrint("amount field has  focus ");
      }
    });
  }

  void _updateFromInitialAmountTotal() {
    /* check which one has focus before updating */
    setState(() {
      if (!_totalFocusNode!.hasFocus) {
        // update fees
        xrint("total field doesnt have  focus ");
        widget.fees = _getFeesFromAmount();
        _feesFieldController!.text = "${widget.fees}";
        _totalAmountFieldController!.removeListener(_updateFromTotal);
        _totalAmountFieldController!.text =
            "${_getRealTotalAmountFromInitial()}";
        _totalAmountFieldController!.addListener(_updateFromTotal);
        // update amount
      } else {
        xrint("total field has  focus ");
      }
    });
  }

  _getFeesFromAmount() {
    String amount = _amountFieldController!.text;
    double amount_;
    if (amount == null || "" == amount.trim())
      amount_ = 0;
    else
      amount_ = double.parse(amount);

    return ((_getFees().toDouble() * amount_.toDouble()) ~/ 100);
  }

  _getFeesFromTotal() {
    String total = _totalAmountFieldController!.text;
    double? total_;
    if (total_ == null || "" == total.trim())
      total_ = 0;
    else {
      total_ = double.parse(total);
    }

    int fees =( total_.toInt() - _getRealInitialAmountFromTotal()).toInt();
    return fees;
  }

  _getRealInitialAmountFromTotal() {
    String _total = _totalAmountFieldController!.text;
    double total;
    if (_total == null || "" == _total.trim())
      total = 0;
    else
      total = double.parse(_total);

    // amount = total / (1+fees)
    return (100 * total / (100.toDouble() + _getFees().toDouble())).toInt();
  }

  _getRealTotalAmountFromInitial() {
    int fees = _getFeesFromAmount();
    String _amount = _amountFieldController!.text;
    int amount;
    if (_amount == null || "" == _amount.trim())
      amount = 0;
    else
      amount = int.parse(_amount);

    return amount + fees;
  }

  @override
  void updateFees(fees_tmoney, fees_flooz, fees_bankcard) {
    setState(() {
      widget.fees_tmoney = fees_tmoney;
      widget.fees_flooz = fees_flooz;
      widget.fees_bankcard = fees_bankcard;
    });
  }

/*
  @override
  void updateFees(int feesPercentage) {
    setState(() {
      widget.feesPercentage = feesPercentage;
    });
  }*/

  @override
  void showGetFeesLoading(bool isGetFeesLoading) {
    setState(() {
      this.isGetFeesLoading = isGetFeesLoading;
    });
  }

  double _getFees() {
    switch (selectedPaymentMode) {
      case 0:
        return widget.fees_tmoney!;
        break;
      case 1:
        return widget.fees_bankcard!;
        break;
      case 2:
        return widget.fees_flooz!;
    }
    return 10.toDouble();
  }

  _getTotalAmountEuro() {
    return double.parse(
        ((_getRealTotalAmountFromInitial() / euroRatio)).toStringAsFixed(2));
  }
}
