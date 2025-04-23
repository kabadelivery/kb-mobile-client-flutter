import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherSubscribeSuccessPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddVouchersPage extends StatefulWidget {
  static var routeName = "/AddVouchersPage";

  AddVoucherPresenter? presenter;

  CustomerModel? customer;

  var qrCode;

  bool autoSubscribe;

  int damage_id;

  AddVouchersPage(
      {Key? key,
      this.damage_id = -1,
      this.customer,
      this.presenter,
      this.qrCode = null,
      this.autoSubscribe = false})
      : super(key: key);

  @override
  _AddVouchersPageState createState() => _AddVouchersPageState();
}

class _AddVouchersPageState extends State<AddVouchersPage>
    implements AddVoucherView {
  TextEditingController _promoCodeFieldController = TextEditingController();

  bool isLaunching = false;
  bool damageError = false;

  bool isValidCode = false;

  @override
  void initState() {
    super.initState();
    widget.presenter!.addVoucherView = this;
    _promoCodeFieldController.addListener(() {
      setState(() {
        isValidCode = _isValidCode(_promoCodeFieldController.text);
      });
    });
    /* check if customer token is not null before moving forward, otherwise, we fetching for that */
    CustomerUtils.getCustomer().then((value) {
      widget.customer = value;
      if (widget.qrCode != null) {
        _promoCodeFieldController.text = widget.qrCode;
        if (_promoCodeFieldController.text?.trim() != "" &&
            _promoCodeFieldController.text?.trim()?.length != null &&
            _promoCodeFieldController.text!.trim()!.length! > 2)
          widget.presenter
              !.subscribeVoucher(widget.customer!, widget.qrCode, isQrCode: true);
      }
      if (widget.damage_id != -1) {
        widget.presenter
            !.subscribeVoucherForDamage(widget.customer!, widget.damage_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('subscribe')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: widget.damage_id != -1
            ? Column(
                children: [
                  SizedBox(height: 50),
                  /* this is space for loading and error button */
                  isLaunching
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        KColors.primaryColor)),
                                height: 40,
                                width: 40),
                            Container(
                              child: Text(
                                "${AppLocalizations.of(context)!.translate("fix_please_wait")}",
                                style: TextStyle(
                                    color: KColors.new_black, fontSize: 14),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 15),
                            )
                          ],
                        )
                      : Container(),
                  damageError
                      ? Column(
                          children: [
                            Container(
                              child: Text(
                                "${AppLocalizations.of(context)!.translate("system_error")}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: KColors.new_black, fontSize: 14),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 15),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, bottom: 15, left: 20, right: 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: MaterialButton(
                                    color: KColors.primaryColor,
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            "${AppLocalizations.of(context)!.translate('try_again')}"
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                        isLaunching
                                            ? Row(
                                                children: <Widget>[
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .white)),
                                                      height: 20,
                                                      width: 20),
                                                ],
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    onPressed: () {
                                      if (widget.damage_id != -1) {
                                        widget.presenter
                                            !.subscribeVoucherForDamage(
                                                widget.customer!,
                                                widget.damage_id);
                                      }
                                    }),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(height: 20),
                ],
              )
            : Column(children: <Widget>[
                SizedBox(height: 20),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('insert_voucher_hint')}",
                        style: TextStyle(
                            fontSize: 14,
                            color: KColors.new_black.withAlpha(150)),
                        textAlign: TextAlign.center)),
                /* input text */
                SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  child: Row(children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('PROMO_CODE')}"),
                    SizedBox(width: 20),
                    Expanded(
                        flex: 7,
                        child: TextField(
                            controller: _promoCodeFieldController,
                            style: TextStyle(fontSize: 20),
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            enabled: !isLaunching,
                            decoration:
                                InputDecoration(border: InputBorder.none)))
                  ]),
                ),
                SizedBox(height: 20),
                Container(
                  margin:
                      EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: MaterialButton(
                        color: isValidCode
                            ? KColors.primaryColor
                            : KColors.primaryColor.withAlpha(150),
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                "${AppLocalizations.of(context)!.translate('subscribe')}"
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
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
                        onPressed: () {
                          iLaunchCodeVerification();
                        }),
                  ),
                ),
              ]),
      ),
    );
  }

  void iLaunchCodeVerification() {
    widget.presenter
        !.subscribeVoucher(widget.customer!, _promoCodeFieldController.text);
  }

  bool _isValidCode(String code) {
    if (code.length < 3) {
      return false;
    }
    return true;
  }

  @override
  void networkError() {
    showLoading(false);
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      damageError = false;
      this.isLaunching = isLoading;
    });
  }

  @override
  void subscribeSuccessError(int error) {
    if (widget.damage_id != -1) {
      /* damage reparation error, show a button to make him try again */
      setState(() {
        damageError = true;
      });
      return;
    }

    // show error dialog
    String errorMessage = "";
    switch (error) {
      case -1: // no voucher
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_no_exist')}";
        break;
      case 400: // invalid parameters
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_invalid_params')}";
        break;
      case -2: // cannot self subscribe
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_no_self_subscribe')}";
        break;
      case -3: // expired
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_expired')}";
        break;
      case -7: // expired
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_not_yet_available')}";
        break;
      case -4: // deactivate
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_disabled')}";
        break;
      case -5: // already subscribe
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_already_subscribed')}";
        break;
      case -6: // max people
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_max_count_reached')}";
        break;
      default:
        errorMessage =
            "${AppLocalizations.of(context)!.translate('voucher_invalid_params')}";
    }
    mDialog(errorMessage);
  }

  @override
  void subscribeSuccessfull(VoucherModel voucher) {
    // open success page
    Navigator.pop(context);
    /*  Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return VoucherSubscribeSuccessPage(voucher: voucher);
        }
    ));*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VoucherSubscribeSuccessPage(voucher: voucher),
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
  }

  @override
  void systemError() {
    showLoading(false);
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
}
