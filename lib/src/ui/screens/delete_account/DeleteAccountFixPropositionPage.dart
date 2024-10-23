import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/delete_account_refund_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMaxiWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/delete_account/DeleteAccountRefundQuestionnaryPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class DeleteAccountFixPropositionPage extends StatefulWidget {
  static var routeName = "/DeleteAccountFixPropositionPage";

  VoucherModel voucher;

  int fixId;

  CustomerModel customer;

  int balance;

  DeleteAccountFixPropositionPage(
      {Key key, this.fixId, this.voucher, this.balance})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeleteAccountFixPropositionPageState();
  }
}

class DeleteAccountFixPropositionPageState
    extends State<DeleteAccountFixPropositionPage> {
  @override
  void initState() {
    super.initState();
    CustomerUtils.getCustomer().then((customer) {
      if (customer != null) {
        widget.customer = customer;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
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
                      "${AppLocalizations.of(context).translate('delete_account')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                width: 140,
                height: 140,
                child: Lottie.asset(LottieAssets.wearesorry),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "${AppLocalizations.of(context).translate('we_wish_to_keep_you')}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              widget.voucher != null
                  ? Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${AppLocalizations.of(context).translate('we_offer_you_voucher')}",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyVoucherMiniWidget(
                          voucher: widget.voucher,
                          pick: false,
                          isGift: true,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () => _getCoupon(),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,
                            decoration: BoxDecoration(
                                color: KColors.primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      /*    Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 10),*/
                                      Text(
                                          "${AppLocalizations.of(context).translate('get_coupon')}"
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(), Container(
                width: 160,
                height: 2,
                color: KColors.new_gray,
                margin: EdgeInsets.symmetric(vertical: 20),
              ),
              GestureDetector(
                onTap: () => _deleteAccount(),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      color: KColors.primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(5)),
                  // color: KColors.new_gray,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            /*    Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 10),*/
                            Text(
                                "${AppLocalizations.of(context).translate('delete_anyway')}"
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: KColors.primaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _deleteAccount() {
    /* move to information retrieval information */
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountRefundQuestionnaryPage(
          presenter: DeleteAccountRefundPresenter(),
          fixId: widget.fixId,
          amountRefunded: widget.balance,
        ),
      ),
    );
  }

  _getCoupon() {
    /* make request to server, and as sa result, move to the other page */
    // clean all pages and go back to setting page, then move to subscribe for voucher page
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            settings: RouteSettings(name: HomePage.routeName),
            builder: (BuildContext context) => HomePage()),
        (r) => false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVouchersPage(
          customer: widget.customer,
          damage_id: widget.fixId,
          presenter: AddVoucherPresenter(),
        ),
      ),
    );
  }
}
