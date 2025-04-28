import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/order_feedback_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/home/orders/CustomerFeedbackPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPageOld extends StatefulWidget {
  static var routeName = "/OrderDetailsPageOld";

  OrderDetailsPresenter? presenter;

  OrderDetailsPageOld({Key? key, this.orderId, this.presenter})
      : super(key: key);

  int? orderId;
  CustomerModel? customer;
  CommandModel? command;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPageOld>
    implements OrderDetailsView {
  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  bool waitedForCustomerOnce = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter!.orderDetailsView = this;
    showLoading(true);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
      if (widget.orderId! != null &&
          widget.orderId! != 0 &&
          widget.command == null &&
          widget.customer != null) {
        widget.presenter!.fetchOrderDetailsWithId(customer!, widget.orderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int args = ModalRoute.of(context)!.settings.arguments as int;
    if (args != null && args != 0) {
      widget.orderId = args;
      if (widget.customer != null && widget.command == null) {
        // there must be a food id.
        widget.presenter!
            .fetchOrderDetailsWithId(widget.customer!, widget.orderId!);
      } else {
        // postpone it to the next second by adding showing the loading button.
        if (!waitedForCustomerOnce) {
          waitedForCustomerOnce = true;
          showLoading(true);
          Future.delayed(Duration(seconds: 1)).then((onValue) {
            if (widget.customer != null && widget.command == null) {
              widget.presenter!
                  .fetchOrderDetailsWithId(widget.customer!, widget.orderId!);
            }
          });
        }
      }
    }

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
                      "${AppLocalizations.of(context)!.translate('order_details')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: MyLoadingProgressWidget())
            : (hasNetworkError
                ? _buildNetworkErrorPage()
                : hasSystemError
                    ? _buildSysErrorPage()
                    : _inflateDetails()));
  }

  var reasonsArray = [
    "menu_not_availabe",
    "restaurant_in_break",
    "restaurant_closed",
    "reason_beyond_control"
  ];

  // <string-array name="motives">
  // <item>Menu is not available</item>
  // <item>Restaurant in Pause</item>
  // <item>Restaurant in Closed</item>
  // <item>Your command has been rejected for reasons beyond our control.</item>
  // </string-array>

  Widget _inflateDetails() {
    return SingleChildScrollView(
        child: Column(
            children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
          color: Utils.getStateColor(widget.command!.state!!),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.command!.is_preorder == 0
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Colors.white.withAlpha(100)),
                          child: Text("Pre",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          padding: EdgeInsets.all(8)),
                  SizedBox(width: 5),
                  Text(_orderTopLabel(widget.command!),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  /* if rejected than we need a reason */
                ],
              ),
              SizedBox(height: 5),
              widget.command!.state! > 3
                  ? Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 300,
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('reason')}: ${_getReason()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w200))),
                        ],
                      ),
                    )
                  : Container()
            ],
          )),
      /* Progress line */
      Container(
        child: _getProgressTimeLine(widget.command!),
        margin: EdgeInsets.only(top: 10, bottom: 10),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          child: RichText(
            text: new TextSpan(
              text:
                  '${AppLocalizations.of(context)!.translate('latest_update')}: ',
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: KColors.new_black),
              children: <TextSpan>[
                TextSpan(
                    text: " ${_orderLastUpdate(widget.command!)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: KColors.new_black.withAlpha(200))),
              ],
            ),
          ),
        ),
      ),
      (widget.command!.state == 3 && widget.command!.rating!! > 1
          ? SizedBox(height: 10)
          : Container()),
      (widget.command!.state == 3 && widget.command!.rating!! > 1
          ? Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
              decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Center(
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('rating')}"
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white))),
                      SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: widget.command!.comment == null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: <Widget>[]..addAll(List<Widget>.generate(
                                widget.command!.rating!, (int index) {
                              return Icon(Icons.star,
                                  color: KColors.primaryYellowColor, size: 20);
                            }))),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                  "${widget.command!.comment == null ? "" : widget.command!.comment} ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17))),
                        ],
                      )
                    ]),
              ))
          : Container()),
      (widget.command!.rating! < 1 &&
              Utils.within3days(widget.command!.last_update!)
          ? SizedBox(height: 10)
          : Container()),
      /* your contact */
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 20, bottom: 20, right: 10, left: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('your_contact')}:",
                      style:
                          TextStyle(color: KColors.new_black, fontSize: 16))),
              Flexible(
                  child: Text(
                      "${widget.command?.shipping_address?.phone_number}",
                      style:
                          TextStyle(color: KColors.new_black, fontSize: 14))),
            ]),
      ),
      SizedBox(height: 10),
      /* command key */
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 20, bottom: 20, right: 10, left: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('command_key')}",
                      style:
                          TextStyle(color: KColors.new_black, fontSize: 16))),
              Flexible(
                  child: Text(
                      "${widget.command!.state! != COMMAND_STATE.WAITING && widget.command!.state! != COMMAND_STATE.REJECTED ? widget.command?.passphrase?.toUpperCase() : "---"}",
                      style: TextStyle(
                          color: KColors.new_black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
            ]),
      ),
    ]
              ..addAll(widget.command!.state! > COMMAND_STATE.COOKING! &&
                      widget.command!.state! < COMMAND_STATE.REJECTED!
                  ? <Widget>[
                      SizedBox(height: 10),
                      /* KABA man name */
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, right: 10, left: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                      "${AppLocalizations.of(context)!.translate('kaba_man_name')}",
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 16))),
                              Flexible(
                                  child: Text(
                                      "${widget.command!.livreur!.name}",
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal))),
                            ]),
                      ),
                      SizedBox(height: 10),
                      /* KABA man phone */
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, right: 10, left: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                      "${AppLocalizations.of(context)!.translate('kaba_man_phone')}",
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 16))),
                              MaterialButton(
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, right: 10, left: 10),
                                  color: KColors.primaryColor,
                                  splashColor: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.phone, color: Colors.white),
                                      SizedBox(width: 5),
                                      Text(
                                          "${widget.command?.livreur?.workcontact}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  onPressed: () {
                                    _callNumber(
                                        widget.command!.livreur!.workcontact!);
                                  }),
                            ]),
                      ),
                    ]
                  : <Widget>[Container()])
              ..addAll(<Widget>[
                SizedBox(height: 10),
                /* not so far from */
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, right: 10, left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "${AppLocalizations.of(context)!.translate('not_far_from')}",
                              style: TextStyle(
                                  color: KColors.new_black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 10),
                          Text("${widget.command?.shipping_address?.near}",
                              style: TextStyle(
                                  color: KColors.new_black, fontSize: 14)),
                        ]),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, right: 10, left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "${AppLocalizations.of(context)!.translate('description')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: KColors.new_black,
                                  fontSize: 16)),
                          SizedBox(height: 10),
                          Text(
                              "${widget.command?.shipping_address?.description}",
                              style: TextStyle(
                                  color: KColors.new_black, fontSize: 14)),
                        ]),
                  ),
                ),
                SizedBox(height: 10),
                widget.command?.infos == null ||
                        widget.command?.infos?.trim()?.length == 0
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        color: CommandStateColor.delivered,
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Text(
                                    "${AppLocalizations.of(context)!.translate('informations')}: ${widget.command!.infos}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color: Colors.white))),
                          ],
                        )),
                SizedBox(height: 10),
                /* food list*/
                Card(
                    child: Column(
                        children: List.generate(
                            widget.command!.food_list!.length, (int index) {
                  return SingleOrderFoodWidget(
                      widget.command!.food_list![index]);
                }))),
                SizedBox(height: 10),
                /* if we have a voucher, we will show it */
                _buildVoucher(),
                SizedBox(height: 10),
                /* bill */
                widget.command!.kaba_point_used_amount != null &&
                        widget.command!.kaba_point_used_amount! > 0
                    ? showKabaPointUsed()
                    : Container(),
                _buildBill(),
              ])));
  }

  String _orderTopLabel(CommandModel command) {
    switch (widget.command!.state!) {
      case 0:
        return "${AppLocalizations.of(context)!.translate('order_waiting')}"
            .toUpperCase();
      case 1:
        return "${AppLocalizations.of(context)!.translate('order_cooking')}"
            .toUpperCase();
      case 2:
        return "${AppLocalizations.of(context)!.translate('order_deliverying')}"
            .toUpperCase();
      case 3:
        return "${AppLocalizations.of(context)!.translate('order_delivered')}"
            .toUpperCase();
        break;
      default:
        return "${AppLocalizations.of(context)!.translate('order_rejected')}"
            .toUpperCase();
    }
  }

  _orderLastUpdate(CommandModel command) {
    return Utils.readTimestamp(
        context, int.parse(widget.command!.last_update!));
  }

  _getProgressTimeLine(CommandModel command) {
    double PROGRESS_ICON_SIZE_PASSIVE = 25, PROGRESS_ICON_SIZE_ACTIVE = 40;
    double LINE_HEIGHT = 40, LINE_WIDTH = 2, MARGIN = 5;
    Color PASSIVE_COLOR = Colors.grey.withAlpha(100);

    return Column(children: <Widget>[
      /* waiting */
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  widget.command!.state! == COMMAND_STATE.WAITING
                      ? Container(
                          decoration: BoxDecoration(
                              color: CommandStateColor.waiting,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('waiting')}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, right: 10, left: 10))
                      : Container(),
                  SizedBox(width: 10),
                ],
              )),
          Expanded(
            flex: 0,
            child: Container(
                child: Icon(Icons.watch_later,
                    size: widget.command!.state! == COMMAND_STATE.WAITING
                        ? PROGRESS_ICON_SIZE_ACTIVE
                        : PROGRESS_ICON_SIZE_PASSIVE,
                    color: widget.command!.state! != COMMAND_STATE.WAITING
                        ? PASSIVE_COLOR
                        : Colors.grey)),
          ),
          Expanded(flex: 2, child: Container()),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(flex: 2, child: Container()),
          Expanded(
              flex: 0,
              child: Container(
                  color: Colors.transparent,
                  child: SizedBox(
                      height: LINE_HEIGHT,
                      width: LINE_WIDTH,
                      child: Container(
                          color: Colors.grey,
                          margin:
                              EdgeInsets.only(top: MARGIN, bottom: MARGIN))))),
          Expanded(flex: 2, child: Container()),
        ],
      ),

      /* cooking */
      Row(
        children: <Widget>[
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 0,
            child: Container(
                child: Icon(FontAwesomeIcons.utensils,
                    size: widget.command!.state! == COMMAND_STATE.COOKING
                        ? PROGRESS_ICON_SIZE_ACTIVE
                        : PROGRESS_ICON_SIZE_PASSIVE,
                    color: widget.command!.state! != COMMAND_STATE.COOKING
                        ? PASSIVE_COLOR
                        : CommandStateColor.cooking)),
          ),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10),
                  widget.command!.state! == COMMAND_STATE.COOKING
                      ? Container(
                          decoration: BoxDecoration(
                              color: CommandStateColor.cooking,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('cooking')}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, right: 10, left: 10))
                      : Container(),
                ],
              ))
        ],
      ),
      Container(
          height: LINE_HEIGHT,
          width: LINE_WIDTH,
          color: CommandStateColor.cooking,
          margin: EdgeInsets.only(top: MARGIN, bottom: MARGIN)),

      /* shipping */
      Row(
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  widget.command!.state! == COMMAND_STATE.SHIPPING
                      ? Container(
                          decoration: BoxDecoration(
                              color: CommandStateColor.shipping,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('shipping')}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, right: 10, left: 10))
                      : Container(),
                  SizedBox(width: 10),
                ],
              )),
          Expanded(
            flex: 0,
            child: Container(
                child: Icon(FontAwesomeIcons.biking,
                    size: widget.command!.state! == COMMAND_STATE.SHIPPING
                        ? PROGRESS_ICON_SIZE_ACTIVE
                        : PROGRESS_ICON_SIZE_PASSIVE,
                    color: widget.command!.state! != COMMAND_STATE.SHIPPING
                        ? PASSIVE_COLOR
                        : CommandStateColor.shipping)),
          ),
          Expanded(flex: 2, child: Container()),
        ],
      ),
      Container(
          height: LINE_HEIGHT,
          width: LINE_WIDTH,
          color: CommandStateColor.shipping,
          margin: EdgeInsets.only(top: MARGIN, bottom: MARGIN)),

      /* delivered */
      Row(
        children: <Widget>[
          Expanded(flex: 2, child: Container()),
          Container(
              child: Icon(Icons.check_circle,
                  size: widget.command!.state! == COMMAND_STATE.DELIVERED
                      ? PROGRESS_ICON_SIZE_ACTIVE
                      : PROGRESS_ICON_SIZE_PASSIVE,
                  color: widget.command!.state! != COMMAND_STATE.DELIVERED
                      ? PASSIVE_COLOR
                      : CommandStateColor.delivered)),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10),
                  widget.command!.state! == COMMAND_STATE.DELIVERED
                      ? Container(
                          decoration: BoxDecoration(
                              color: CommandStateColor.delivered,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('delivered')}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, right: 10, left: 10))
                      : Container(),
                ],
              ))
        ],
      ),
    ]);
  }

  @override
  Future<void> inflateOrderDetails(CommandModel command) async {
    // showLoading(false);
    setState(() {
      widget.command = command;
    });

    // this will happen 2 seconds after
  }

  _reviewOrder() async {
    if (widget.command!.rating! < 1 &&
        Utils.within3days(widget.command!.last_update!) &&
        widget.command!.state == 3 /*within 3 days, you can still do it.*/) {
      // must review.
      /* jump to review pager. */
      Map results = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OrderFeedbackPage(
                  orderId: widget.command!.id!,
                  presenter: OrderFeedbackPresenter(OrderFeedbackView())),
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

      if (results != null && results.containsKey('ok')) {
        bool feedBackOk = results['ok'];
        if (feedBackOk) {
          widget.presenter!
              .fetchOrderDetailsWithId(widget.customer!, widget.command!.id!);
        }
      }
    } else {
      // can't review or we don't have to review.
//        Toast.show("cant post review", context);
    }
  }

  @override
  void logoutTimeOutSuccess() {
    // TODO: implement logoutTimeOutSuccess
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasNetworkError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void systemError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasSystemError = true;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          widget.presenter!
              .fetchOrderDetailsWithId(widget.customer!, widget.orderId!);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          widget.presenter!
              .fetchOrderDetailsWithId(widget.customer!, widget.orderId!);
        });
  }

  _buildBill() {
    int? priceNormalCommand,
        priceActualCommand,
        priceTotalToPay,
        priceNormalDelivery,
        priceActualDelivery;

    priceNormalCommand = widget.command!.food_pricing!;

    bool showRemise = true, showDeliveryNormal = true, showFoodNormal = true;

    // depends
    if (widget.command!.is_preorder == 1) {
      priceTotalToPay = widget.command!.preorder_food_pricing!;
      priceActualCommand = widget.command!.preorder_food_pricing!;
      priceActualDelivery = widget.command!.preorder_shipping_pricing!;
      priceNormalCommand = widget.command!.food_pricing!;
      priceNormalDelivery = widget.command!.shipping_pricing!;
    } else if (widget.command!.is_promotion == 1) {
      priceTotalToPay = widget.command!.promotion_total_pricing!;
      priceActualCommand = widget.command!.promotion_food_pricing!;
      priceActualDelivery = widget.command!.promotion_shipping_pricing!;
      priceNormalCommand = widget.command!.food_pricing!;
      priceNormalDelivery = widget.command!.shipping_pricing!;
    } else if (widget.command!.is_promotion == 0 &&
        widget.command!.is_preorder == 0) {
      priceTotalToPay = widget.command!.total_pricing!;
      priceActualCommand = widget.command!.food_pricing!;
      priceActualDelivery = widget.command!.shipping_pricing!;
      showRemise = false;
      showDeliveryNormal = false;
      showFoodNormal = false;
    }

    return Card(
        child: Container(
      padding: EdgeInsets.all(10),
      child: Column(children: <Widget>[
//                      SizedBox(height: 10),
//                      "/web/assets/app_icons/promo_large.gif"
        (int.parse(widget.command!.remise!) > 0
            ? Container(
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink(
                            "/web/assets/app_icons/promo_large.gif")))))
            : Container()),
        Container(),
        /* content */
        SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${AppLocalizations.of(context)!.translate('order_amount')}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              /* check if there is promotion on Commande */
              Row(
                children: <Widget>[
                  Row(
                    // only show if there is promotion on food
                    children: <Widget>[
                      Text("($priceNormalCommand)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15)),
                      SizedBox(width: 5),
                    ],
                  ),
                  Text("${priceActualCommand}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
        SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                  "${AppLocalizations.of(context)!.translate('delivery_amount')}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              /* check if there is promotion on Livraison */
              Row(
                children: <Widget>[
                  widget.command!.is_preorder == 1 ||
                          widget.command!.is_promotion == 1
                      ? Row(
                          // only show if there is pre-order or promotion on the fees of delivery
                          children: <Widget>[
                            Text("($priceNormalDelivery)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 15)),
                            SizedBox(width: 5),
                          ],
                        )
                      : Container(),
                  Text("${priceActualDelivery}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
        SizedBox(height: 10),
        int.parse(widget.command!.remise!) > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('discount')}:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey)),
                    /* check if there is remise */
                    Text("-${widget.command!.remise!}%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: CommandStateColor.delivered)),
                  ])
            : Container(),

        SizedBox(height: 10),
        Center(
            child: Container(
                width: MediaQuery.of(context).size.width - 10,
                color: KColors.new_black,
                height: 1)),
        SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${AppLocalizations.of(context)!.translate('net_price')}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                  "${widget.command!.is_preorder == 0 ? priceTotalToPay : widget.command!.preorder_total_pricing}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: KColors.primaryColor,
                      fontSize: 18)),
            ]),
        SizedBox(height: 10),
        (int.parse(widget.command!.remise!) > 0
            ? Container(
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink(
                            "/web/assets/app_icons/promo_large.gif")))))
            : Container()),
      ]),
    ));
  }

  Future<void> _callNumber(String workcontact) async {
    var url = "tel:+228${workcontact}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      Toast.show("Call error");
    }
  }

  _buildVoucher() {
    // build voucher if we have it
    if (widget.command != null &&
        widget.command!.voucher_entity != null &&
        widget.command!.voucher_entity?.id != null) {
      return MyVoucherMiniWidget(voucher: widget.command!.voucher_entity);
    }
    return Container();
  }

  _getReason() {
    if (widget.command!.reason! >= reasonsArray.length)
      return "${AppLocalizations.of(context)!.translate('reason_beyond_control')}";
    return "${AppLocalizations.of(context)!.translate('${reasonsArray[widget.command!.reason! - 1 < 0 ? 0 : widget.command!.reason! - 1]}')}";
  }

  showKabaPointUsed() {
    // kaba_point_used_amount
    return Container(
        child: RichText(
            text: TextSpan(
                text:
                    "${AppLocalizations.of(context)!.translate("kaba_point_used_amount")}",
                style: TextStyle(color: Colors.white, fontSize: 12),
                children: <TextSpan>[
              TextSpan(
                  text: "${widget.command!.kaba_point_used_amount}  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))
            ])),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: KColors.primaryColor));
  }
}
