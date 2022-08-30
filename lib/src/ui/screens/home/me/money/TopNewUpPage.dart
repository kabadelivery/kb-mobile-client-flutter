import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:smart_select/smart_select.dart';

class TopNewUpPage extends StatefulWidget {
  static var routeName = "/TopNewUpPage";

  TopUpPresenter presenter;

  var total = 0;

  var fees = 0;

  double fees_tmoney = 10.0;

  double fees_flooz = 10.0;

  double fees_bankcard = 10.0;

  int selectedPosition = 1;

  TopNewUpPage({Key key, this.presenter}) : super(key: key);

  CustomerModel customer;

  @override
  _TopNewUpPageState createState() => _TopNewUpPageState();
}

class _TopNewUpPageState extends State<TopNewUpPage> implements TopUpView {
  TextEditingController _phoneNumberFieldController;
  TextEditingController _amountFieldController;
  TextEditingController _totalAmountFieldController;

  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  double euroRatio = 657.60;

  String feesDescription = "";
  bool isGetFeesLoading = false;
  FocusNode _totalFocusNode, _amountFocusNode;

  // int selectedPaymentMode = 0; // 0 tmoney 1 bank card 2 flooz

  TextEditingController _feesFieldController;

  int BANK_MIN_AMOUNT = 10000;

  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = KColors.new_black,
      filter_active_text_color = Colors.white;

  var _searchChoices = null;

  var dropdownValue = "Tmoney";

  @override
  void initState() {
    super.initState();
    widget.presenter.topUpView = this;
    _phoneNumberFieldController = new TextEditingController();
    _totalAmountFieldController = new TextEditingController();
    _amountFieldController = new TextEditingController();
    _feesFieldController = new TextEditingController();

    _phoneNumberFieldController.addListener(_checkOperator);
    _amountFieldController.addListener(_updateFromInitialAmountTotal);
    _totalAmountFieldController.addListener(_updateFromTotal);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.fetchFees(widget.customer);
//      widget.presenter.fetchTopUpConfiguration(widget.customer);
    });

    _totalFocusNode = new FocusNode();
    _amountFocusNode = new FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feesDescription =
        "${AppLocalizations.of(context).translate('why_top_up_fees')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_searchChoices == null) {
      _searchChoices = [
        "${AppLocalizations.of(context)?.translate("mobile_money_top_up")}",
        "${AppLocalizations.of(context)?.translate("bank_card_top_up")}"
      ];
    }
    return Scaffold(
      backgroundColor: Colors.white,
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
                    "${AppLocalizations.of(context).translate('top_up')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Container(height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: <Widget>[
                SizedBox(height: 15),
                /* define mobile money and visa-card */
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: filter_unactive_button_color,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(5.0)),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () => _onSwitch(1),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(Utils.capitalize(
                                                    // "${AppLocalizations.of(context).translate('search_restaurant')}"),
                                                    _searchChoices[0]),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: widget
                                                                .selectedPosition ==
                                                            1
                                                        ? this
                                                            .filter_active_text_color
                                                        : this
                                                            .filter_unactive_text_color)),
                                          ),
                                          decoration: BoxDecoration(
                                              color: widget.selectedPosition == 1
                                                  ? this.filter_active_button_color
                                                  : this
                                                      .filter_unactive_button_color,
                                              borderRadius:
                                                  new BorderRadius.circular(5.0)))),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: InkWell(
                                      onTap: () => _onSwitch(2),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(
                                                Utils.capitalize(_searchChoices[1]),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: widget
                                                                .selectedPosition ==
                                                            1
                                                        ? this
                                                            .filter_unactive_text_color
                                                        : this
                                                            .filter_active_text_color)),
                                          ),
                                          decoration: BoxDecoration(
                                              color: widget.selectedPosition == 1
                                                  ? this
                                                      .filter_unactive_button_color
                                                  : this.filter_active_button_color,
                                              borderRadius:
                                                  new BorderRadius.circular(5.0)))),
                                ),
                              ]),
                          duration: Duration(milliseconds: 3000),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                widget.selectedPosition == 1
                    ? Container(
                        decoration: BoxDecoration(
                            color: KColors.new_gray,
                            borderRadius: BorderRadius.circular(5)),
                        margin:
                            EdgeInsets.only( right: 10, left: 10),
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child:
                            // usage example
                            DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          underline: Container(),
                          icon: const Icon(FontAwesomeIcons.chevronDown,
                              size: 15, color: KColors.primaryColor),
                          elevation: 16,
                          style: const TextStyle(
                              color: KColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          hint: Text(
                              "${AppLocalizations.of(context).translate('choose_mobile_money_service')}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14)),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: <String>[
                            'Tmoney',
                            'Flooz',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ))
                    : Container(),

                widget.selectedPosition == 1
                    ? Column(children: [
                        SizedBox(height: 30),
                        /* phone number just in case we are working with moov*/
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
                                            "${AppLocalizations.of(context).translate('topup_phone_number')}",
                                        children: [
                                          TextSpan(
                                              text: " *",
                                              style: TextStyle(
                                                  color: KColors.primaryColor))
                                        ],
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey))),
                                SizedBox(height: 5),
                                Container(
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
                                      keyboardType: TextInputType.phone),
                                )
                              ]),
                        ),
                      ])
                    : Container(),
                Column(children: [
                  SizedBox(height: 15),
                  /* amount you wanna get paid */
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
                                      "${AppLocalizations.of(context).translate('amount_to_topup')}",
                                  children: [
                                    TextSpan(
                                        text: " *",
                                        style: TextStyle(color: KColors.primaryColor))
                                  ],
                                  style:
                                      TextStyle(fontSize: 12, color: Colors.grey))),
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
                                        "${AppLocalizations.of(context).translate('currency')}",
                                        style:
                                            TextStyle(color: KColors.primaryColor)),
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

                Column(children: [
                  SizedBox(height: 10),
                  /* amount you wanna get paid */
                  Container(
                    color: KColors.new_gray,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: RichText(
                                    text: TextSpan(
                                        text:
                                            "${AppLocalizations.of(context).translate('fees')} ",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        children: [
                                          isGetFeesLoading
                                              ? TextSpan(
                                                  text: "---",
                                                  style: TextStyle(
                                                      color: KColors.mGreen,
                                                      fontWeight: FontWeight.bold))
                                              : TextSpan(
                                                  text: "(${_getFees()}%)",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: KColors.primaryColor,
                                                      fontWeight: FontWeight.normal))
                                        ]),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${widget?.fees}",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 14, color: KColors.new_black),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            "${AppLocalizations.of(context).translate('currency')}",
                                            style: TextStyle(
                                                color: KColors.primaryColor,
                                                fontSize: 14))
                                      ],
                                    ),
                                  ))
                            ]),
                        SizedBox(height: 10),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${AppLocalizations.of(context).translate('total_amount')}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14))),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: TextField(
                                        controller: _totalAmountFieldController,
                                        enabled: false,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: KColors.primaryColor),
                                        decoration: InputDecoration(
                                            fillColor: Colors.yellow,
                                            border: InputBorder.none,
                                            hintMaxLines: 5,
                                            hintStyle: TextStyle(fontSize: 13)),
                                        keyboardType: TextInputType.number),
                                  ))
                            ]),
                      ],
                    ),
                  ),
                ]),

               false ? Center(
                    child: Text(
                  "${AppLocalizations.of(context).translate('total_amount')}: ${_getTotalAmountEuro()} €",
                  style: TextStyle(color: KColors.mBlue, fontSize: 14),
                )) : Container(),

                SizedBox(height: 50)
              ]),
            ),
            Positioned(
              child: Container(width: MediaQuery.of(context).size.width,
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          color: KColors.primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: GestureDetector(
                        onTap: () {
                          iLaunchTransaction();
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                  "${AppLocalizations.of(context).translate('top_up')}"
                                      .toUpperCase(),
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                              SizedBox(width: 10),
                              Text(
                                  "${_totalAmountFieldController.text} ${_totalAmountFieldController.text.trim() == "" ? "" : AppLocalizations.of(context).translate('currency')}",
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
           bottom: 0, left: 0,
            ),
          ],
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
  }

  @override
  void topUpToPush() {
    Navigator.of(context).pop({'check_balance': true});
  }

  bool _checkOperator() {
    String number = "${_phoneNumberFieldController.text}";

    String mOperator = "---";
    isOperatorOk = true;

    if (Utils.isPhoneNumber_TGO(number)) {
      if (Utils.isPhoneNumber_Moov(number)) {
        mOperator = "MOOV";
        setState(() {
          dropdownValue = "Flooz";
        });
      } else if (Utils.isPhoneNumber_Tgcel(number)) {
        mOperator = "TOGOCEL";
        setState(() {
          dropdownValue = "Tmoney";
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
          "${AppLocalizations.of(context).translate('please_wait_fees_percentage')}");
      return;
    }

    if (widget.selectedPosition == 1 &&
        !Utils.isPhoneNumber_TGO(_phoneNumberFieldController.text)) {
      mToast("${AppLocalizations.of(context).translate('phone_number_wrong')}");
    } else {
      if (widget.customer != null) {
        if (widget.selectedPosition == 1) {
          widget.presenter.launchTopUp(
              widget.customer,
              "${_phoneNumberFieldController.text}",
              "${_amountFieldController.text}",
              _getFees());
        } else if (widget.selectedPosition == 2) {
          // launch pay dunya
          String amount = "${_amountFieldController.text}";
          int _amount = int.parse(amount);
          if (_amount >= BANK_MIN_AMOUNT)
            widget.presenter.launchPayDunya(
                widget.customer, "${_amountFieldController.text}", _getFees());
          else
            mDialog(
                "${AppLocalizations.of(context).translate(
                    'bank_card_top_up_min')} ${BANK_MIN_AMOUNT}");
        } else {
          mToast("${AppLocalizations.of(context).translate('system_error')}");
        }
      } else
        mToast("${AppLocalizations.of(context).translate('system_error')}");
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
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
                          svgIcons,
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
                          "${AppLocalizations.of(context).translate('refuse')}",
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
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
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
      if (!_amountFocusNode.hasFocus) {
        // update fees
        xrint("amount field doesnt have focus ");
        _amountFieldController.removeListener(_updateFromInitialAmountTotal);
        _amountFieldController.text = "${_getRealInitialAmountFromTotal()}";
        _amountFieldController.addListener(_updateFromInitialAmountTotal);
        widget.fees = _getFeesFromTotal();
        _feesFieldController.text = "${widget.fees}";
        // update amount
      } else {
        xrint("amount field has  focus ");
      }
    });
  }

  void _updateFromInitialAmountTotal() {
    /* check which one has focus before updating */
    setState(() {
      if (!_totalFocusNode.hasFocus) {
        // update fees
        xrint("total field doesnt have  focus ");
        widget.fees = _getFeesFromAmount();
        _feesFieldController.text = "${widget.fees}";
        _totalAmountFieldController.removeListener(_updateFromTotal);
        _totalAmountFieldController.text =
            "${_getRealTotalAmountFromInitial()}";
        _totalAmountFieldController.addListener(_updateFromTotal);
        // update amount
      } else {
        xrint("total field has  focus ");
      }
    });
  }

  _getFeesFromAmount() {
    String amount = _amountFieldController.text;
    double amount_;
    if (amount == null || "" == amount.trim())
      amount_ = 0;
    else
      amount_ = double.parse(amount);

    return ((_getFees().toDouble() * amount_.toDouble()) ~/ 100);
  }

  _getFeesFromTotal() {
    String total = _totalAmountFieldController.text;
    double total_;
    if (total_ == null || "" == total.trim())
      total_ = 0;
    else {
      total_ = double.parse(total);
    }

    int fees = total_.toInt() - _getRealInitialAmountFromTotal();
    return fees;
  }

  _getRealInitialAmountFromTotal() {
    String _total = _totalAmountFieldController.text;
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
    String _amount = _amountFieldController.text;
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
    switch (widget.selectedPosition) {
      case 2:
        return widget.fees_bankcard;
        break;
      case 1:
        if (dropdownValue == "Tmoney")
          return widget.fees_tmoney;
        else if (dropdownValue == "Flooz") return widget.fees_flooz;
    }
    return 10.toDouble();
  }

  _getTotalAmountEuro() {
    return double.parse(
        ((_getRealTotalAmountFromInitial() / euroRatio)).toStringAsFixed(2));
  }

  _onSwitch(int i) {
    setState(() {
      widget.selectedPosition = i;
    });
  }
}
