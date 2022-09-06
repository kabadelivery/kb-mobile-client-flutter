import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/chat_voucher_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatVoucherWidget extends StatefulWidget {
  String voucher_link;

  VoucherModel voucher;

  String voucher_code;

  CustomerModel customer;

  ChatVoucherPresenter presenter;

  ChatVoucherWidget(
      {Key key,
      this.customer,
      this.voucher_link,
      this.voucher = null,
      this.presenter}) {
    List<String> splits = voucher_link.split("/");
    voucher_code = splits[splits.length - 1];
  }

  @override
  _ChatVoucherWidgetState createState() {
    return _ChatVoucherWidgetState();
  }
}

class _ChatVoucherWidgetState extends State<ChatVoucherWidget>
    implements ChatVoucherView {
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // launch presenter to get voucher details
    widget.presenter.chatVoucherView = this;
    widget.presenter.fetchVoucherDetails(widget.customer, widget.voucher_code);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                child: LoadingAnimationWidget.prograssiveDots(
                  color: KColors.primaryColor,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (hasError) {
      return Container();
    } else {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.circular(5)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        "${widget?.voucher?.value} ${widget?.voucher?.type == 1 ? "F" : "%"} OFF",
                        style: TextStyle(
                            fontSize: 12,
                            color: KColors.primaryColor,
                            fontWeight: FontWeight.normal),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    Text(
                      "${widget?.voucher?.type == 1 ? "${AppLocalizations.of(context).translate('voucher_type_shop')}" : (widget?.voucher?.type == 2 ? "${AppLocalizations.of(context).translate('voucher_type_delivery')}" : "${AppLocalizations.of(context).translate('voucher_type_all')}")}",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.voucher?.value}",
                      style: TextStyle(
                          fontSize: 22,
                          color: KColors.primaryYellowColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${widget?.voucher_code}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text("${AppLocalizations.of(context).translate("expires_at")}\n${widget?.voucher?.end_date}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.normal)),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          widget.voucher == null
              ? InkWell(
                  onTap: () {
                    _subscribeToVoucher();
                  },
                  child: Container(
                    child: Center(
                        child: Text(
                      "${AppLocalizations.of(context).translate("subscribe")}"
                          ?.toUpperCase(),
                      style: TextStyle(
                          color: KColors.primaryColor,
                          fontWeight: FontWeight.w500),
                    )),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: KColors.primaryColor.withAlpha(20)),
                  ))
              : Container()
        ],
      );
    }
  }

  void _subscribeToVoucher() {
    _jumpToPage(
        context,
        AddVouchersPage(
            presenter: AddVoucherPresenter(),
            qrCode: "${widget.voucher_code}".toUpperCase(),
            autoSubscribe: true,
            customer: widget.customer));
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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
  void inflateVoucher(VoucherModel voucher) {
    widget.voucher = voucher;
  }

  @override
  void networkError() {
    setState(() {
      isLoading = false;
      hasError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isLoading = true;
      hasError = false;
    });
  }

  @override
  void systemError() {
    setState(() {
      isLoading = false;
      hasError = true;
    });
  }
}
