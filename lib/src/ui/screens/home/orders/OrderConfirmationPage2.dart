import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/DeliveryTimeFrameModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopNewUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/_static_data/NetworkImages.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:KABA/src/xrint.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulsator/pulsator.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class OrderConfirmationPage2 extends StatefulWidget {
  static var routeName = "/OrderConfirmationPage2";

  Map<ShopProductModel, int>? addons, foods;

//  int totalPrice;

  OrderConfirmationPresenter? presenter;

  CustomerModel? customer;

  int? orderOrPreorderChoice = 0;

  ShopModel? restaurant;

  int? orderTimeRangeSelected = 0;

  OrderConfirmationPage2(
      {Key? key, this.presenter, this.foods, this.addons, this.restaurant})
      : super(key: key);

  @override
  _OrderConfirmationPage2State createState() => _OrderConfirmationPage2State();
}

class _OrderConfirmationPage2State extends State<OrderConfirmationPage2>
    implements OrderConfirmationView {
  DeliveryAddressModel? _selectedAddress;
  VoucherModel? _selectedVoucher;

  /* pricing configuration */
  OrderBillConfiguration _orderBillConfiguration = OrderBillConfiguration();

  bool isConnecting = false;
  bool isPayAtDeliveryLoading = false;
  bool isPreorderLoading = false;
  bool isPayNowLoading = false;

  bool checkIsRestaurantOpenConfigIsLoading = true;

  TextEditingController? _addInfoController;

  bool _checkOpenStateError = false;

  VoucherModel? _oldSelectedVoucher = null;

  _OrderConfirmationPage2State();

  List<String> dayz = [];

  GlobalKey poweredByKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _listController = new ScrollController();
    _addInfoController = new TextEditingController();
    this.widget.presenter!.orderConfirmationView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // check opening state of the restaurant
      widget.presenter!.checkOpeningStateOf(customer!, widget.restaurant!);
    });

    /* check if customer is logged in, if not, open login page for him shortly, and bring him back after... */
  }

  bool _usePoint = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    dayz = [
      "${AppLocalizations.of(context)!.translate('monday_long')}",
      "${AppLocalizations.of(context)!.translate('tuesday_long')}",
      "${AppLocalizations.of(context)!.translate('wednesday_long')}",
      "${AppLocalizations.of(context)!.translate('thursday_long')}",
      "${AppLocalizations.of(context)!.translate('friday_long')}",
      "${AppLocalizations.of(context)!.translate('saturday_long')}",
      "${AppLocalizations.of(context)!.translate('sunday_long')}",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                }),
            backgroundColor: KColors.primaryYellowColor,
            centerTitle: true,
            title: Text(
                "${AppLocalizations.of(context)!.translate('confirm_order')}",
                style: TextStyle(fontSize: 16))),
        // check if the restaurant is open before showing anything.
        body: (isPayAtDeliveryLoading == true ||
                isPayNowLoading == true ||
                isPreorderLoading == true)
            ? Container(
                height: MediaQuery.of(context).size.height,
                child: Center(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // loading page.
                        SizedBox(
                            child: MyLoadingProgressWidget(),
                            height: 80,
                            width: 80),
                        SizedBox(height: 30),
                        Text(
                          "${AppLocalizations.of(context)!.translate('processing_payment')}",
                          textAlign: TextAlign.center,
                        )
                      ]),
                )),
              )
            : (checkIsRestaurantOpenConfigIsLoading
                ? Center(child: MyLoadingProgressWidget())
                : (_checkOpenStateError ||
                        (_orderBillConfiguration != null &&
                            _orderBillConfiguration.open_type! >= 0 &&
                            _orderBillConfiguration.open_type! <= 3)
                    ? _buildOrderConfirmationPage2()
                    : ErrorPage(
                        onClickAction: () => widget.presenter
                            !.checkOpeningStateOf(
                                widget.customer!, widget.restaurant!)))));
  }

  Future _pickDeliveryAddress() async {
    setState(() {
//      _orderBillConfiguration = null;
      _orderBillConfiguration.isBillBuilt = false;
      _selectedAddress = null;
      _orderBillConfiguration.kaba_point = null;
    });

    /* jump and get it */
    Map results = await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyAddressesPage(pick: true, presenter: AddressPresenter(AddressView())),
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

    if (results != null && results.containsKey('selection')) {
      setState(() {
        _selectedAddress = results['selection'];
      });
      /* update / refresh this page */
      this.widget.presenter!.orderConfirmationView = this;
      CustomerUtils.getCustomer().then((customer) {
        widget.customer = customer;

        // launch request for retrieving the delivery prices and so on.
        widget.presenter!.computeBilling(widget.restaurant!, widget.customer!,
            widget.foods!, _selectedAddress!, _selectedVoucher, _usePoint);
        showLoading(true);
        Future.delayed(Duration(seconds: 1), () {
          Scrollable.ensureVisible(poweredByKey.currentContext!);
        });
      });
    }
  }

  _buildAddress(DeliveryAddressModel? selectedAddress) {
    if (selectedAddress == null)
      return Container();
    else
      return Container(
        color: KColors.new_gray,
        margin: EdgeInsets.only(left: 20, right: 20),
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(Utils.capitalize(selectedAddress.name??""),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: KColors.new_black,
                              fontSize: 14))),
                  SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(children: <Widget>[
                      Expanded(
                          child: Text(
                              Utils.capitalize(selectedAddress.description??""),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey))),
                    ]),
                  )
                ]),
            Positioned(
                top: 5,
                right: 0,
                child: InkWell(
                    child: Container(
                        child: Icon(Icons.delete_forever,
                            size: 20, color: KColors.primaryColor),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        padding: EdgeInsets.all(8)),
                    onTap: () {
                      /* remove address */
                      setState(() {
                        _selectedAddress = null;
                      });
                    }))
          ],
        ),
      );
  }

  _buildEligibleVoucher(List<VoucherModel>? eligible_vouchers) {
    if (eligible_vouchers == null)
      return Container();
    else
      return Container(
        color: KColors.new_gray,
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
            children: List.generate(eligible_vouchers.length, (index) {
          if (eligible_vouchers[index].id == _selectedVoucher?.id ||
              eligible_vouchers[index].use_count! -
                      eligible_vouchers[index].already_used_count! ==
                  0)
            return Container(
                /* padding: EdgeInsets.only(
                    right: 10,
                    left: 10,
                    top: index == 0 ? 10 : 0,
                    bottom: index == eligible_vouchers.length - 1 ? 10 : 0)*/
                );
          return Container(
            padding: EdgeInsets.only(
                right: 10,
                left: 10,
                top: index == 0 ? 10 : 5,
                bottom: index == eligible_vouchers.length - 1 ? 10 : 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                              child: Text(
                                "${eligible_vouchers[index].value} ${eligible_vouchers[index].type == 1 ? "F" : "%"} OFF",
                                style: TextStyle(
                                    color: KColors.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: KColors.primaryColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(30))),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "${eligible_vouchers[index].type == 1 ? "${AppLocalizations.of(context)!.translate('voucher_type_shop')}" : (eligible_vouchers[index].type == 2 ? "${AppLocalizations.of(context)!.translate('voucher_type_delivery')}" : "${AppLocalizations.of(context)!.translate('voucher_type_all')}")}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: KColors.new_black))
                        ]),
                        SizedBox(height: 5),
                        Text(eligible_vouchers[index].trade_name!,
                            style: TextStyle(color: Colors.grey, fontSize: 12))
                      ]),
                  GestureDetector(
                    onTap: () {
                      _selectVoucher(
                          has_voucher: true, voucher: eligible_vouchers[index]);
                    },
                    child: Container(
                      child: Text(
                          "${AppLocalizations.of(context)!.translate('voucher_use')}",
                          style: TextStyle(
                              fontSize: 14,
                              color: KColors.primaryColor,
                              fontWeight: FontWeight.w600)),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          color: KColors.primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  )
                ]),
          );
        })),
      );
  }

  _buildBill() {
    if (_orderBillConfiguration == null) return Container();
    if (_isPreorderSelected()) {
      return Container(
          decoration: BoxDecoration(
              color: KColors.new_gray,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.all(10),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              NetworkImages.kaba_promotion_gif))))),
              Container(),
              /* content */
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                    "${AppLocalizations.of(context)!.translate('invoice_bill')}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey))
              ]),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('order_amount')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12)),
                    /* check if there is promotion on Commande */
                    Row(
                      children: <Widget>[
                        /* montant commande normal */
                        Text(
                            "${_orderBillConfiguration!.command_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('delivery_amount')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12)),
                    /* check if there is promotion on Livraison */
                    Row(
                      children: <Widget>[
                        /* montant livraison normal */
                        Text(
                            "${_orderBillConfiguration!.shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: KColors.new_black,
                                fontSize: 12)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      color: KColors.buy_category_button_bg,
                      height: 1)),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('net_price')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    /* montant total a payer */
                    Text("${_orderBillConfiguration!.total_normal_pricing} F",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: KColors.primaryColor,
                            fontSize: 14)),
                  ]),
              SizedBox(height: 10),
              (Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              NetworkImages.kaba_promotion_gif)))))),
            ]),
          ));
    } else
      return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
              color: KColors.new_gray,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.all(10),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              (_orderBillConfiguration!.remise! > 0 && !_isPreorder()
                  ? Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  Utils.inflateLink(
                                      NetworkImages.kaba_promotion_gif)))))
                  : Container()),
              Container(),
              /* content */
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                    "${AppLocalizations.of(context)!.translate('invoice_bill')}",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
              ]),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('order_amount')}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                    /* check if there is promotion on Commande */
                    Row(
                      children: <Widget>[
                        /* montant commande normal */
                        Text(
                            _orderBillConfiguration!.command_pricing! >
                                    _orderBillConfiguration!.promotion_pricing!
                                ? "(${_orderBillConfiguration!.command_pricing})"
                                : "",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                                fontSize: 12)),
                        SizedBox(width: 5),
                        /* montant commande promotion */
                        Text(
                            _orderBillConfiguration!.command_pricing! >
                                    _orderBillConfiguration!.promotion_pricing!
                                ? "${_orderBillConfiguration!.promotion_pricing} ${AppLocalizations.of(context)!.translate('currency')}"
                                : "${_orderBillConfiguration!.command_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('delivery_amount')}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                    /* check if there is promotion on Livraison */
                    Row(
                      children: <Widget>[
                        /* montant livraison normal */
                        Text(
                            _orderBillConfiguration!.shipping_pricing! >
                                    _orderBillConfiguration
                                        !.promotion_shipping_pricing!
                                ? "(${_orderBillConfiguration!.shipping_pricing})"
                                : "",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                                fontSize: 12)),
                        SizedBox(width: 5),
                        /* montant livraison promotion */
                        Text(
                            _orderBillConfiguration!.shipping_pricing! >
                                    _orderBillConfiguration
                                        !.promotion_shipping_pricing!
                                ? "${_orderBillConfiguration!.promotion_shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}"
                                : "${_orderBillConfiguration!.shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              //additional_fees
              _orderBillConfiguration!.additional_fees_total_price!=0||_orderBillConfiguration!.additional_fees_total_price!=null?
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('additional_fees')}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                    /* check if there is promotion on Livraison */
                    Row(
                      children: <Widget>[
                        /* montant livraison promotion */
                        Text(
                           "${_orderBillConfiguration.additional_fees_total_price} ${AppLocalizations.of(context)!.translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),

                      ],
                    )
                  ])
                  :Container(),
              SizedBox(height: 10),
              Container(
                decoration:BoxDecoration(
                  color:Color(0x54B6B6B6),
                  borderRadius:BorderRadius.circular(5)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('additional_fees_description')}",
                      style: TextStyle(

                          fontSize: 12,
                          color: Colors.black)),
                ),

              ),
              SizedBox(height: 10),
              _orderBillConfiguration!.remise! > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Text(
                              "${AppLocalizations.of(context)!.translate('discount')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey)),
                          /* montrer le discount s'il y'a lieu */
                          Text("-${_orderBillConfiguration!.remise!}%",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: CommandStateColor.delivered)),
                        ])
                  : Container(),
              SizedBox(height: 10),
              Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      color: Colors.grey.shade300,
                      height: 1)),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context)!.translate('net_price')}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    /* montant total a payer */
                    Text(
                        "${_orderBillConfiguration!.total_pricing!} ${AppLocalizations.of(context)!.translate('currency')}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: KColors.primaryColor,
                            fontSize: 14)),
                  ]),
              SizedBox(height: 10),
              ((_orderBillConfiguration!.remise! > 0 && !_isPreorder())
                  ? Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  Utils.inflateLink(
                                      NetworkImages.kaba_promotion_gif)))))
                  : Container()),
            ]),
          ));
  }

  _cookingTimeEstimation() {
    return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: KColors.new_gray),
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                  "${AppLocalizations.of(context)!.translate('cooking_time_estimation')}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey)),
              Text(
                  "${AppLocalizations.of(context)!.translate('min_short_on_average')}",
                  style: TextStyle(
                      color: KColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600))
            ]));
  }

  _buildDeliveryCoupon() {
    return Stack(children: <Widget>[
      Positioned(
          left: 10,
          bottom: 10,
          child: Icon(Icons.directions_bike,
              size: 40, color: Colors.white.withAlpha(50))),
//      Center(child: Icon(Icons.add_circle, color: Colors.white)),
      Center(
        child:
            Text("-50%", style: TextStyle(fontSize: 40, color: Colors.white)),
      )
    ]);
  }

  Widget _buildOrderConfirmationPage2() {
    /* we get this one ... then we tend to select and address to end the purchase. */

    return SingleChildScrollView(
//      controller: _listController,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[SizedBox(height: 20)]
            ..add(Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: KColors.new_gray,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                  children: [
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, bottom: 5),
                  child: Row(children: [
                    Text(
                        "${AppLocalizations.of(context)!.translate('order_summary')}",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 13))
                  ]),
                )
              ]..addAll(_buildFoodList())),
            ))
            // restaurant is closed and we can't do nothing
            ..addAll((_orderBillConfiguration.hasCheckedOpen == true &&
                    _orderBillConfiguration.can_preorder == 0 &&
                    _orderBillConfiguration.open_type! != 1)
                ? <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin:
                                EdgeInsets.only(top: 40, right: 20, left: 20),
                            decoration: BoxDecoration(
                                color: KColors.primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.all(10),
                            child: Text(
                                "Sorry,the restaurant is closed right now. Please come back later or contact our Customer Care. \nThank you",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white))),
                        SizedBox(height: 10),
                        SizedBox(
                            height: 120,
                            child: SvgPicture.asset(
                              VectorsData.closed_shop_svg,
                            ))
                      ],
                    )
                  ]
                : <Widget>[
                    _cookingTimeEstimation(),
                    SizedBox(height: 10),
                    _buildRadioPreorderChoice(),
                    SizedBox(height: 10),
                    Container(
                        child: (widget.orderOrPreorderChoice == 1 &&
                                    _orderBillConfiguration.open_type! == 1 &&
                                    _orderBillConfiguration.can_preorder ==
                                        1) ||
                                (_orderBillConfiguration.can_preorder == 1 &&
                                    _orderBillConfiguration.open_type! != 1 &&
                                    widget.orderOrPreorderChoice == 0)
                            ? _buildDeliveryTimeFrameList()
                            : Container(),
                        color: Colors.white),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      color: KColors.new_gray,
                      child: TextField(
                          controller: _addInfoController,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          style:
                              TextStyle(color: KColors.new_black, fontSize: 14),
                          decoration: InputDecoration(
                            labelText:
                                "${AppLocalizations.of(context)!.translate('additional_info')}",
                            border: InputBorder.none,
                          )),
                    ),
                    SizedBox(height: 10),
                    /* choose a delivery address */
                    InkWell(
                        splashColor: Colors.white,
                        child: Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: KColors.mBlue.withAlpha(30)),
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    BouncingWidget(
                                      duration: Duration(milliseconds: 400),
                                      scaleFactor: 2,
                                      onPressed: () {  },
                                      child: Icon(Icons.location_on,
                                          size: 28, color: KColors.mBlue),
                                    ),
                                  ]),
                                  SizedBox(width: 10),
                                  Text(
                                      "${AppLocalizations.of(context)!.translate('choose_delivery_address')}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: KColors.mBlue))
                                ])),
                        onTap: () {
                          _pickDeliveryAddress();
                        }),
                    _buildAddress(_selectedAddress),
                    SizedBox(key: poweredByKey, height: 25),
                    _usePoint ? Container() : _buildCouponSpace(),
                    _usePoint ? Container() : SizedBox(height: 15),
                    isConnecting
                        ? Center(child: MyLoadingProgressWidget())
                        : Container(),
                    SizedBox(height: 20),
                    _orderBillConfiguration != null &&
                            _orderBillConfiguration!.isBillBuilt == true
                        ?
                        // check if out of range before doing anything.
                        _orderBillConfiguration!.out_of_range == true
                            ? _buildOutOfRangePage()
                            : (Column(children: <Widget>[
                                /* _orderBillConfiguration!.kaba_point?.is_eligible == true && _orderBillConfiguration!.kaba_point?.can_be_used == true
                        && */
                                _selectedVoucher == null
                                    ? _buildPointDiscountOption()
                                    : Container(),

                                SizedBox(height: 30),
                                _buildBill(),
                                SizedBox(height: 10),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  padding: EdgeInsets.only(
                                      left: 20, right: 10, top: 20, bottom: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          "${AppLocalizations.of(context)!.translate('your_balance')}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(width: 10),
                                      Text(
                                          "${StateContainer.of(context).balance == null ? "---" : StateContainer.of(context).balance} ${AppLocalizations.of(context)!.translate('currency')}",
                                          style: TextStyle(
                                              color: KColors.primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 10,
                                              bottom: 10),
                                          decoration: BoxDecoration(
                                              color: KColors.primaryColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: InkWell(
                                              child: Text(
                                                  "${AppLocalizations.of(context)!.translate('top_up')}"
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              onTap: () => _topUpAccount())),
                                    ],
                                  ),
                                ),
                                _isPreorderSelected()
                                    ? SizedBox(height: 10)
                                    : Container(),
                                // purchase buttons are becoming cards.
                                _isPreorderSelected()
                                    ? _buildPreOrderButton()
                                    : Container(),
                                !_isPreorderSelected()
                                    ? SizedBox(height: 10)
                                    : Container(),
                                !_isPreorderSelected()
                                    ? _buildOrderNowButton()
                                    : Container(),
                                !_isPreorderSelected()
                                    ? SizedBox(height: 10)
                                    : Container(),
                                !_isPreorderSelected()
                                    ? _buildOrderPayAtArrivalButton()
                                    : Container(),
                                SizedBox(height: 30),
                              ]))
                        : Container(),
                    Center(
                        child: InkWell(
                      onTap: () => _jumpToRecoverPage(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.questionCircle,
                                color: Colors.grey),
                            SizedBox(width: 5),
                            Text(
                                "${AppLocalizations.of(context)!.translate('lost_your_password')}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )),
                    SizedBox(height: 20)
                  ])),
    );
  }

  @override
  void logoutTimeOutSuccess() {
    /*logout is something else*/
  }

  @override
  void networkError() {
    showLoading(false);
    setState(() {
      checkIsRestaurantOpenConfigIsLoading = false;
    });
    mToast("${AppLocalizations.of(context)!.translate('network_error')}");
  }

  @override
  void systemError() {
    showLoading(false);
    setState(() {
      checkIsRestaurantOpenConfigIsLoading = false;
    });
    mToast("${AppLocalizations.of(context)!.translate('system_error')}");
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isConnecting = isLoading;
      if (!isLoading) {
        isPayNowLoading = false;
        isPayAtDeliveryLoading = false;
        isPreorderLoading = false;
      }
    });
  }

  void mToast(String message) {
    Toast.show(message, duration: Toast.lengthLong);
  }

  _jumpToRecoverPage() {
    /* can back once the password is changed */
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage(
            presenter: RecoverPasswordPresenter(RecoverPasswordView()), is_a_process: true),
      ),
    );
  }

  @override
  void inflateBillingConfiguration(OrderBillConfiguration configuration) {
    setState(() {
      _orderBillConfiguration = configuration;
    });
    showLoading(false);
  }

  _buildPurchaseButtonsOld() {
    if (_orderBillConfiguration == null) return Container();

    return Column(children: <Widget>[
      // pay at arrival button
      _orderBillConfiguration!.pay_at_delivery == true
          ? // pay at delivery and not having ongoing delivery right now.
          Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        side: BorderSide(color: Colors.transparent)),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 10, left: 10),
                    color: KColors.mBlue,
                    splashColor: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.directions_bike, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                            "${AppLocalizations.of(context)!.translate('pay_at_delivery')}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    onPressed: () {}),
              ],
            )
          : Container(
              child: Text(
                  "${AppLocalizations.of(context)!.translate('cant_pay_at_delivery')}")),
      SizedBox(height: 20),
      // pay immediately button
      _orderBillConfiguration!.account_balance! != null &&
              _orderBillConfiguration.prepayed! &&
              _orderBillConfiguration!.account_balance! >
                  _orderBillConfiguration!.total_pricing!
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        side: BorderSide(color: Colors.transparent)),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 10, left: 10),
                    color: KColors.primaryColor,
                    splashColor: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.moneyBill, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                            "${AppLocalizations.of(context)!.translate('pay_now')}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    onPressed: _payNow()),
              ],
            )
          : Container(
              child: Text(
              "${AppLocalizations.of(context)!.translate('cant_prepay_balance_insufficient')}",
              style: TextStyle(
                  fontSize: 16,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold),
            )),
      SizedBox(height: 50)
    ]);
  }

  /* _buildPurchaseButtons() {
    return Column(children: <Widget>[
      SizedBox(height: 10),
      */ /* your account balance is */ /*
      Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: RichText(
              text: TextSpan(
                  text: '${AppLocalizations.of(context)!.translate('your_balance_is')} ',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(text: "${Utils.inflatePrice(
                        "${_orderBillConfiguration!.account_balance!}")} ${AppLocalizations.of(context)!.translate('currency')}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: KColors.primaryColor, fontSize: 16),
                    )
                  ]
              ),
            ),
          )
      ),
      SizedBox(height: 30),
      */ /* is your balance sufficient for the purchase ?*/ /*
      _orderBillConfiguration!.account_balance! != null &&
          _orderBillConfiguration.prepayed! &&
          _orderBillConfiguration!.account_balance! >
              _orderBillConfiguration!.total_pricing! ?
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(color: Colors.transparent)),
              padding: EdgeInsets.only(
                  top: 10, bottom: 10, right: 10, left: 10),
              color: KColors.primaryColor,
              splashColor: Colors.white,
              child:
              Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.moneyBill, color: Colors.white),
                  SizedBox(width: 10),
                  Text("${AppLocalizations.of(context)!.translate('pay_now')}", style: TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                  isPayNowLoading ? Row(
                    children: <Widget>[
                      SizedBox(width: 10),
                      SizedBox(child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white)), height: 15, width: 15),
                    ],
                  ) : Container(),
                ],
              ),
              onPressed: () => _payNow()),
        ],
      ) : (!_orderBillConfiguration.prepayed! ?
      Container(margin: EdgeInsets.only(left: 20, right: 20),
          child: Text(
              "${AppLocalizations.of(context)!.translate('restaurant_no_allow_prepay')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold)))
          : Container(child: Text(
          "${AppLocalizations.of(context)!.translate('balance_insufficient')}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14,
              color: KColors.primaryColor,
              fontWeight: FontWeight.bold)))),
      SizedBox(height: 20),
      */ /* check if you can post pay */ /*
      _orderBillConfiguration.pay_at_delivery &&
          _orderBillConfiguration.trustful == 1 ? (
          _orderBillConfiguration.max_pay >
              _orderBillConfiguration.total_pricing ?
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.transparent)),
                  padding: EdgeInsets.only(
                      top: 10, bottom: 10, right: 10, left: 10),
                  color: KColors.mBlue,
                  splashColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.directions_bike, color: Colors.white),
                      SizedBox(width: 5),
                      Text("${AppLocalizations.of(context)!.translate('pay_at_delivery')}", style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                      isPayAtDeliveryLoading ? Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          SizedBox(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors
                                  .white)), height: 15, width: 15),
                        ],
                      ) : Container(),
                    ],
                  ),
                  onPressed: () => _payAtDelivery(false)),
            ],
          ) :
          Container(margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                  "${AppLocalizations.of(context)!.translate('cant_pay_at_delivery_max_pay_reached')} (${_orderBillConfiguration
                      .max_pay})",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14,
                      color: KColors.mBlue,
                      fontWeight: FontWeight.normal))
          )
      ) :
      (_orderBillConfiguration.trustful == 0 ?
      Container(margin: EdgeInsets.only(left: 20, right: 20),
          child: Text(
              "${AppLocalizations.of(context)!.translate('cant_pay_because_ongoing_order')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.mBlue,
                  fontWeight: FontWeight.normal))) :
      (!_orderBillConfiguration.pay_at_delivery ?
      Container(margin: EdgeInsets.only(left: 20, right: 20),
          child: Text("${AppLocalizations.of(context)!.translate('restaurant_no_allow_pay_at_delivery')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.mBlue,
                  fontWeight: FontWeight.normal)))
          : Container())),
      SizedBox(height: 30),
    ]);
  }
*/
  _payNow() async {
    // 1. get password
    var results = await Navigator.of(context)
        .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return RetrievePasswordPage(type: 3);
    }));
    // retrieve password then do it,
    if (results != null &&
        results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null ||
          results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
      } else {
        String _mCode = results['code'];
        /* we can't continue because you are using a demo account */
        if ("${widget.customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) ==
            0) {
          sorryDemoAccountAlert();
        } else {
          showLoadingPreorder(true);
          if (Utils.isCode(_mCode)) {
            widget.presenter!.payNow(
                widget.customer!,
                widget.foods!,
                _selectedAddress!,
                _mCode,
                _addInfoController!.text!,
                _selectedVoucher!,
                _usePoint);
          } else {
            mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
          }
        }
      }
    }
//    _playMusicForSuccess();
  }

  _payAtDelivery(bool isDialogShown) async {
    // if untrustful, you can't go further.
    if (_orderBillConfiguration!.trustful != 1) {
      if (Utils.isEmailValid(widget.customer!.username!)) {
        // email account
        _showDialog(
          iccon: VectorsData.questions, // untrustful
          message:
              "${AppLocalizations.of(context)!.translate('sorry_email_account_no_pay_delivery')}",
          isYesOrNo: false,
        );
      } else {
        _showDialog(
          iccon: VectorsData.questions, // untrustful
          message:
              "${AppLocalizations.of(context)!.translate('sorry_ongoing_order')}",
          isYesOrNo: false,
        );
      }
      return;
    }

    if (!isDialogShown) {
      _showDialog(
          iccon: VectorsData.questions,
          message:
              "${AppLocalizations.of(context)!.translate('prevent_pay_at_delivery')}",
          isYesOrNo: true,
          actionIfYes: () => _payAtDelivery(true));
      return;
    }

    // 1. get password
    var results = await Navigator.of(context)
        .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return RetrievePasswordPage(type: 3);
    }));
    // retrieve password then do it,
    if (results != null &&
        results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null ||
          results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
      } else {
        String _mCode = results['code'];

        if ("${widget.customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) ==
            0) {
          sorryDemoAccountAlert();
        } else {
          showLoadingPayAtDelivery(true);
          if (Utils.isCode(_mCode)) {
            await widget.presenter!.payAtDelivery(
                widget.customer!,
                widget.foods!,
                _selectedAddress!,
                _mCode,
                _addInfoController!.text!,
                _selectedVoucher,
                _usePoint);
          } else {
            mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
          }
        }
      }
    }
  }

  _payPreorder(bool isDialogShown) async {
    DeliveryTimeFrameModel selectedFrame;

    // if there is no choosen time range then error with toast
    if (widget.orderTimeRangeSelected! >= 0 &&
        widget.orderTimeRangeSelected! <
            _orderBillConfiguration.deliveryFrames!.length)
      selectedFrame =
          _orderBillConfiguration.deliveryFrames![widget.orderTimeRangeSelected!];
    else {
      _showDialog(
          icon: Icon(Icons.error),
          message:
              "${AppLocalizations.of(context)!.translate('choose_delivery_frame')}");
      return;
    }

    if (!isDialogShown) {
      _showDialog(
          iccon: VectorsData.questions,
          message:
              "${AppLocalizations.of(context)!.translate('food_will_be_delivered_on')} ${Utils.timeStampToDayDate(selectedFrame.start!, dayz: dayz)} ${AppLocalizations.of(context)!.translate('between')} ${Utils.timeStampToHourMinute(selectedFrame.start!)} ${AppLocalizations.of(context)!.translate('and')} ${Utils.timeStampToHourMinute(selectedFrame.end!)}",
          isYesOrNo: true,
          actionIfYes: () => _payPreorder(true));
      return;
    }

    // 1. get password
    var results = await Navigator.of(context)
        .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return RetrievePasswordPage(type: 3);
    }));
    // retrieve password then do it,
    if (results != null &&
        results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null ||
          results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
      } else {
        String _mCode = results['code'];

        if ("${widget.customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) ==
            0) {
          sorryDemoAccountAlert();
        } else {
          showLoadingPayAtDelivery(true);
          if (Utils.isCode(_mCode)) {
            await widget.presenter!.payPreorder(
                widget.customer!,
                widget.foods!,
                _selectedAddress!,
                _mCode,
                _addInfoController!.text!,
                selectedFrame.start!,
                selectedFrame.end!);
        } else {
            mToast("${AppLocalizations.of(context)!.translate('wrong_code')}");
          }
        }
      }
    }
  }

  void _showDialog(
      {String? iccon,
      Icon? icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function? actionIfYes,
      String? asset_png = null}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: asset_png != null
                      ? Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              // shape: BoxShape.circle,
                              image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: new AssetImage(asset_png),
                          )))
                      : (icon == null
                          ? SvgPicture.asset(
                              iccon!,
                            )
                          : icon)),
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
                    //
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        if (!okBackToHome) {
                          Navigator.of(context).pop();
                        } else {
                          StateContainer.of(context)
                              .updateTabPosition(tabPosition: 2);
                          Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute(
                                  settings:
                                      RouteSettings(name: HomePage.routeName),
                                  builder: (BuildContext context) =>
                                      HomePage()),
                              (r) => false);
                        }
                      },
                    ),
                  ]);
      },
    );
  }

  void showPayNowLoading(bool isLoading) {
    /* and hide all the other buttons. */
    setState(() {
      isPayNowLoading = isLoading;
    });
  }

  void showLoadingPayAtDelivery(bool isLoading) {
    setState(() {
      isPayAtDeliveryLoading = isLoading;
    });
  }

  void showLoadingPreorder(bool isLoading) {
    setState(() {
      isPreorderLoading = isLoading;
    });
  }

  Future<void> _playMusicForSuccess() async {
    // play music
    final player = AudioPlayer();
    player.play(UrlSource(MusicData.command_success_hold_on));
    if (await Vibration.hasVibrator()==true) {
      Vibration.vibrate(duration: 500);
    }
  }

  @override
  void launchOrderResponse(int errorCode) {
    showLoadingPayAtDelivery(false);
//    mToast("launchOrderResponse ${errorCode}");

    showLoadingPayAtDelivery(false);
    showLoadingPreorder(false);
    showPayNowLoading(false);

    if (errorCode == 0) {
      CustomerUtils.unlockBestSellerVersion();
      _showOrderSuccessDialog();
    } else {
      String message = "";
      switch (errorCode) {
        case 300:
          message =
              "${AppLocalizations.of(context)!.translate('300_wrong_password')}";
          break;
        case 301: // restaurant doesnt exist
          message =
              "${AppLocalizations.of(context)!.translate('301_server_issue')}";
          break;
        case 302:
          message =
              "${AppLocalizations.of(context)!.translate('302_unable_pay_at_arrival')}";
          break;
        case 303:
          message =
              "${AppLocalizations.of(context)!.translate('303_unable_online_payment')}";
          break;
        case 304:
          message =
              "${AppLocalizations.of(context)!.translate('304_address_error')}";
          break;
        case 305:
          message =
              "${AppLocalizations.of(context)!.translate('305_308_balance_insufficient')}";
          break;
        case 306:
          message =
              "${AppLocalizations.of(context)!.translate('306_account_error')}";
          break;
        case 307:
          message =
              "${AppLocalizations.of(context)!.translate('307_unable_preorder')}";
          break;
        case 308:
          message =
              "${AppLocalizations.of(context)!.translate('305_308_balance_insufficient')}";
          break;
        default:
          message =
              "${AppLocalizations.of(context)!.translate('309_system_error')}";
      }
      _showDialog(
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.red),
        message: message,
        isYesOrNo: false,
      );
    }
  }

  /* void _showOrderFailureDialog() {
    _showDialog(
      icon: Icon(FontAwesomeIcons.exclamationTriangle, color: KColors.new_black),
      message: "Sorry, there is a problem with your order. Please try again.",
      isYesOrNo: false,
    );
  }*/

  void _showOrderSuccessDialog() {
    /* save the order, in spending ... */
    _playMusicForSuccess();
    _showDialog(
      okBackToHome: true,
      iccon: VectorsData.delivery_nam,
      message:
          "${AppLocalizations.of(context)!.translate('order_congratz_praise')}",
      isYesOrNo: false,
    );
  }

  _buildRadioPreorderChoice() {
    // different cases.
    if (_orderBillConfiguration == null) {
      return;
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _orderBillConfiguration.open_type! == 0
              ? Container(
                  decoration: BoxDecoration(
                      color: KColors.mBlue,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: EdgeInsets.all(10),
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('sorry_restaurant_close')}\n\n${AppLocalizations.of(context)!.translate('open_time')} ${_orderBillConfiguration.working_hour}\n\n${AppLocalizations.of(context)!.translate('try_preordering')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)))
              : Container(),
          _orderBillConfiguration.open_type! == 1
              ? Row(children: <Widget>[
                  Radio(
                      value: 0,
                      groupValue: widget.orderOrPreorderChoice,
                      onChanged: _handleOrderTypeRadioValueChange),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('order_get_delivered_now_hint')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: widget.orderOrPreorderChoice == 0
                                      ? KColors.primaryColor
                                      : Colors.grey,
                                  fontSize: widget.orderOrPreorderChoice == 0
                                      ? 12
                                      : 12)))),
                ])
              : Container(),
          SizedBox(height: 10),
          _orderBillConfiguration.can_preorder == 1 &&
                  _orderBillConfiguration.open_type! == 1
              ? Row(children: <Widget>[
                  Radio(
                      value: 1,
                      groupValue: widget.orderOrPreorderChoice,
                      onChanged: _handleOrderTypeRadioValueChange),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('preorder_now_hint')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: widget.orderOrPreorderChoice == 1
                                      ? KColors.primaryColor
                                      : Colors.grey,
                                  fontSize: widget.orderOrPreorderChoice == 1
                                      ? 12
                                      : 12)))),
                ])
              : (_orderBillConfiguration.can_preorder == 1 &&
                      _orderBillConfiguration.open_type! != 1
                  ? Row(children: <Widget>[
                      Radio(
                          value: 0,
                          groupValue: widget.orderOrPreorderChoice,
                          onChanged: _handleOrderTypeRadioValueChange),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('preorder_now_hint')}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: widget.orderOrPreorderChoice == 1
                                          ? KColors.primaryColor
                                          : KColors.new_black,
                                      fontSize:
                                          widget.orderOrPreorderChoice == 1
                                              ? 12
                                              : 12)))),
                    ])
                  : Container())
        ],
      ),
    );
  }

  /* pre order button */
  _buildPreOrderButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: () => _payPreorder(false),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.access_time),
                      SizedBox(width: 5),
                      Text(
                          "${AppLocalizations.of(context)!.translate('confirm_preorder')}",
                          style: TextStyle(
                              fontSize: 18,
                              color: KColors.new_black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                      "${AppLocalizations.of(context)!.translate('delivery_discount')} (-${_orderBillConfiguration.discount}%)",
                      style:
                          TextStyle(fontSize: 16, color: KColors.primaryColor)),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('preorder_desc')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    margin: EdgeInsets.only(left: 10, right: 10),
                  ),
                  SizedBox(height: 10),
                  Text("${_orderBillConfiguration.total_preorder_pricing} F",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: KColors.primaryYellowColor)),
                ]),
          ),
        ),
      ),
    );
  }

  /* order and pay now */
  _buildOrderNowButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
      child: InkWell(
        onTap: () => _payNow(),
        child: Container(
          decoration: BoxDecoration(
              color: KColors.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          padding: EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.wallet, color: Colors.white),
                    SizedBox(width: 10),
                    Text("${AppLocalizations.of(context)!.translate('pay_now')}",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('pay_with_kaba_balance')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  margin: EdgeInsets.only(left: 10, right: 10),
                ),
              ]),
        ),
      ),
    );
  }

  /* order and pay at arrival */
  _buildOrderPayAtArrivalButton() {
    return _orderBillConfiguration.pay_at_delivery == true
        ? Container(
            decoration: BoxDecoration(
                color: KColors.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: InkWell(
              onTap: () => _payAtDelivery(false),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.directions_bike,
                              color: KColors.primaryColor),
                          SizedBox(width: 5),
                          Text(
                              "${AppLocalizations.of(context)!.translate('pay_at_arrival')}",
                              style: TextStyle(
                                fontSize: 18,
                                color: KColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Text(
                            "${AppLocalizations.of(context)!.translate('pay_with_cash_at_delivery')}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: KColors.primaryColor)),
                        margin: EdgeInsets.only(left: 10, right: 10),
                      ),
                    ]),
              ),
            ),
          )
        : Container(
            child: Text(
                "${AppLocalizations.of(context)!.translate('cant_pay_at_delivery')}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 20, right: 20),
          );
  }

  void _handleOrderTypeRadioValueChange(int? value) {
    setState(() {
      widget.orderOrPreorderChoice = value;
    });
  }

  _buildDeliveryTimeFrameList() {
    if (_orderBillConfiguration == null ||
        _orderBillConfiguration.deliveryFrames == null) return Container();

    return Column(
        children: <Widget>[]..addAll(List.generate(
              _orderBillConfiguration.deliveryFrames!.length, (index) {
            return Container(
                margin: const EdgeInsets.only(
                    top: 8.0, bottom: 8, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // left date, time,
                    // right checkbox
                    Row(children: <Widget>[
                      Container(
                        child: Text(
                            "${Utils.timeStampToDayDate(_orderBillConfiguration.deliveryFrames![index].start!, dayz: dayz)}",
                            style: TextStyle(color: Colors.white)),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: CommandStateColor.delivered),
                      ),
                      SizedBox(width: 10),
                      Text(
                          "${Utils.timeStampToHourMinute(_orderBillConfiguration.deliveryFrames![index].start!)} - ${Utils.timeStampToHourMinute(_orderBillConfiguration.deliveryFrames![index].end!)}"),
                    ]),
                    Radio(
                        value: index,
                        groupValue: widget.orderTimeRangeSelected!,
                        onChanged: _timeFrameCheckBoxOnChange),
                  ],
                ));
          })));
  }

  _timeFrameCheckBoxOnChange(value) {
    setState(() {
      widget.orderTimeRangeSelected = value;
    });
  }

  _buildFoodList() {
    List<Widget> foodList = [];
    int s = 0;
    widget.foods!.forEach((k, v) {
      foodList.add(_buildBasketItem(k, v));
      if (s < widget.foods!.length - 1) {
        foodList.add(Center(
            child: Container(
                color: Colors.grey.withAlpha(100),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 0.5)));
      } else {
        foodList.add(SizedBox(height: 10));
      }
      s++;
    });
    return foodList;
  }

  Widget _buildBasketItem(ShopProductModel food, int quantity) {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        child: InkWell(
            child: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.only(left: 10),
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Utils.inflateLink(food.pic!)))),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: KColors.primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      child: Row(children: <Widget>[
                        SizedBox(width: 2),
                        Text("${food?.price}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: KColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: food.promotion != 0
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        SizedBox(width: 2),
                        (food.promotion != 0
                            ? Text("${food?.promotion_price}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: KColors.primaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal))
                            : Container()),
                        SizedBox(width: 3),
                        Text(
                            "${AppLocalizations.of(context)!.translate('currency')}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: KColors.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    quantity > 1
                        ? Text(" X ${quantity}",
                            style: TextStyle(
                                color: KColors.new_black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))
                        : Container(
                            width: 24,
                          )
                  ],
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${Utils.capitalize(food.name!)}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: KColors.new_black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // add-up the buttons at the right side of it
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    // margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                ],
              )
            ],
          ),
        )));
  }

  @override
  void networkOpeningStateError() {
    // opening state error
    setState(() {
      checkIsRestaurantOpenConfigIsLoading = false;
      _checkOpenStateError = true;
    });
  }

  @override
  void systemOpeningStateError() {
    // opening state error.
    setState(() {
      checkIsRestaurantOpenConfigIsLoading = false;
      _checkOpenStateError = true;
      _usePoint = false;
    });
  }

  @override
  void inflateBillingConfiguration1(OrderBillConfiguration configuration) {
    setState(() {
      _orderBillConfiguration = configuration;
      _orderBillConfiguration.hasCheckedOpen = true;
    });
    if (_orderBillConfiguration.open_type! == 1) {
      /*  if (StateContainer.of(context).selectedAddress != null) {
        _selectedAddress = StateContainer.of(context).selectedAddress;
        Future.delayed(new Duration(milliseconds: 300), () {
          widget.presenter!.computeBilling(widget.restaurant!, widget.customer!,
              widget.foods, _selectedAddress, _selectedVoucher, _usePoint);
        });
        Future.delayed(Duration(seconds: 1), () {
          Scrollable.ensureVisible(poweredByKey.currentContext);
        });
        showLoading(true);
//        Timer(Duration(milliseconds: 100), () => _listController.jumpTo(_listController.position.maxScrollExtent));
        Future.delayed(Duration(milliseconds: 300), () {
          Scrollable.ensureVisible(poweredByKey.currentContext);
        });
      }*/
    }
  }

  @override
  void inflateBillingConfiguration2(OrderBillConfiguration configuration) {
    StateContainer.of(context).balance = configuration.account_balance;
    _orderBillConfiguration.account_balance = configuration.account_balance;
    _orderBillConfiguration.max_pay = configuration.max_pay;
    _orderBillConfiguration.out_of_range = configuration.out_of_range;
    _orderBillConfiguration.pay_at_delivery = configuration.pay_at_delivery;
    _orderBillConfiguration.cooking_time = configuration.cooking_time;
    _orderBillConfiguration.prepayed = configuration.prepayed;
    _orderBillConfiguration.trustful = configuration.trustful;

    _orderBillConfiguration.shipping_pricing = configuration.shipping_pricing;
    _orderBillConfiguration.command_pricing = configuration.command_pricing;
    _orderBillConfiguration.promotion_pricing = configuration.promotion_pricing;
    _orderBillConfiguration.promotion_shipping_pricing =
        configuration.promotion_shipping_pricing;
    _orderBillConfiguration.total_normal_pricing =
        configuration.total_normal_pricing;
    _orderBillConfiguration.total_pricing = configuration.total_pricing;
    _orderBillConfiguration.remise = configuration.remise;
    _orderBillConfiguration.kaba_point = configuration.kaba_point;
    _orderBillConfiguration.eligible_vouchers = configuration.eligible_vouchers;
    _orderBillConfiguration.additional_fees = configuration.additional_fees;
    _orderBillConfiguration.additional_fees_total_price = configuration.additional_fees_total_price;

    _orderBillConfiguration
        .total_preorder_pricing = (configuration.command_pricing!.toDouble() +
            ((100 - int.parse(_orderBillConfiguration.discount!).toDouble()) *
                configuration.shipping_pricing!.toDouble() /
                100))
        .toInt();

    setState(() {
      _orderBillConfiguration.isBillBuilt = true;
    });
//    Timer(Duration(milliseconds: 1000), () => _listController.jumpTo(_listController.position.maxScrollExtent));
    Future.delayed(Duration(milliseconds: 500), () {
      Scrollable.ensureVisible(poweredByKey.currentContext!);
    });
  }

  @override
  void isRestaurantOpenConfigLoading(bool isLoading) {
    setState(() {
      _checkOpenStateError = false;
      checkIsRestaurantOpenConfigIsLoading = isLoading;
    });
  }

  _isPreorderSelected() {
    if ((_orderBillConfiguration.can_preorder == 1 &&
            _orderBillConfiguration.open_type! == 1) &&
        widget.orderOrPreorderChoice == 1) return true;
    if ((_orderBillConfiguration.can_preorder == 1 &&
            _orderBillConfiguration.open_type! != 1) &&
        widget.orderOrPreorderChoice == 0) return true;
    return false;
  }

  @override
  void isPurchasing(bool isPurchasing) {
    setState(() {
      isPayNowLoading = true;
      isPayAtDeliveryLoading = true;
      isPreorderLoading = true;
    });
  }

  _isPreorder() {
    return ((widget.orderOrPreorderChoice == 1 &&
            _orderBillConfiguration.open_type! == 1 &&
            _orderBillConfiguration.can_preorder == 1) ||
        (_orderBillConfiguration.can_preorder == 1 &&
            _orderBillConfiguration.open_type! != 1 &&
            widget.orderOrPreorderChoice == 0));
  }

  _buildOutOfRangePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 20, right: 20, left: 20),
            decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            padding: EdgeInsets.all(10),
            child: Text(
                "${AppLocalizations.of(context)!.translate('out_of_delivery_range')}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white))),
        SizedBox(height: 10),
        SizedBox(
            height: 120,
            child: SvgPicture.asset(
              VectorsData.out_of_range,
            )),
        SizedBox(height: 30),
      ],
    );
  }

  _topUpAccount() async {
    // jump to topup page.
    var results = await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TopNewUpPage(presenter: TopUpPresenter(TopUpView())),
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

    if (results != null && results.containsKey('check_balance')) {
//      bool check_balance =  results['check_balance'];
      String link = results['link'];
      if (results['check_balance'] == true) {
        // show a dialog that tells the user to check his balance after he has topup up.
        link = Uri.encodeFull(link);
        _launchURL(link);
        _showDialog_(
            message:
                "${AppLocalizations.of(context)!.translate('please_check_balance')}",
            svgIcon: VectorsData.account_balance);
      }
    }
  }

  Future<dynamic> _showDialog_({
    String? svgIcon,
    var message,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(height: 80, width: 80, child: SvgPicture.asset(svgIcon!)),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: <Widget>[
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
                    side: MaterialStateProperty.all(
                        BorderSide(color: KColors.primaryColor, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('accept')}",
                    style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _jumpToPage(
                      context,
                      TransactionHistoryPage(
                          presenter: TransactionPresenter(TransactionView())));
                },
              ),
            ]);
      },
    );
  }

  Future<dynamic> _launchURL(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      try {
        throw 'Could not launch $url';
      } catch (_) {
        xrint(_);
      }
    }
    return -1;
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  _selectVoucher({bool has_voucher = false, VoucherModel? voucher}) async {
    /* just like we pick and address, we pick a voucher. */

    /* we go on the package list for vouchers, and we make a request to show those that are adapted for the foods
    * selected and the current restaurant.
    *
    * RESULT MAY BE:
    *
    * - result may be only vouchers,
    *
    * */
    Map results;
    if (!has_voucher) {
      setState(() {
        _selectedVoucher = null;
      });

      /* jump and get it */
      results = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyVouchersPage(
              pick: true,
              presenter: VoucherPresenter(VoucherView()),
              restaurantId: widget?.restaurant?.id,
              foods: _getFoodsIdArray(widget.foods!)),
        ),
      );
    } else {
      results = new Map();
      results["voucher"] = voucher;
    }

    if (results != null && results.containsKey('voucher')) {
      setState(() {
        _selectedVoucher = results['voucher'];
      });

      if (_selectedAddress != null) {
        this.widget.presenter!.orderConfirmationView = this;
        CustomerUtils.getCustomer().then((customer) {
          widget.customer = customer;

          widget.presenter!.computeBilling(widget.restaurant!, widget.customer!,
              widget.foods!, _selectedAddress!, _selectedVoucher!, _usePoint);
          Future.delayed(Duration(seconds: 1), () {
            Scrollable.ensureVisible(poweredByKey.currentContext!);
          });
          showLoading(true);
//        Timer(Duration(milliseconds: 100), () => _listController.jumpTo(_listController.position.maxScrollExtent));
          Future.delayed(Duration(milliseconds: 500), () {
            Scrollable.ensureVisible(poweredByKey.currentContext!);
          });
        });
      }
    }
  }

  _buildCouponSpace() {
    // if there is not address, we can say we are not building anything.
    if (_isPreorderSelected()) {
      return Container();
    }

    if (_selectedVoucher == null) {
      return Column(children: <Widget>[
        SizedBox(height: 10),
        /* do you have a voucher you want to use ? */
        InkWell(
          onTap: () => _selectVoucher(),
          child: Shimmer(
            duration: Duration(seconds: 2),
            //Default value
            color: Colors.white,
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [KColors.primaryYellowColor, Colors.yellow]),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                /* please choose a voucher. */
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.add, color: KColors.white),
                              onPressed: () => _selectVoucher()),
                          IconButton(
                              icon: Icon(FontAwesomeIcons.ticketAlt,
                                  color: Colors.white),
                              onPressed: () => _selectVoucher())
                        ],
                      ),
                      Text(
                          "${AppLocalizations.of(context)!.translate('add_coupon')}",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ])),
          ),
        ),
        _buildEligibleVoucher(_orderBillConfiguration.eligible_vouchers)
      ]);
    }
    else {
//      _selectedVoucher
      return Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: MyVoucherMiniWidget(
                      voucher: _selectedVoucher, isForOrderConfirmation: true)),
              Positioned(
                  right: 10,
                  top: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue,
//                borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: IconButton(
                            icon: Icon(Icons.delete_forever,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedVoucher = null;
                              });
                              this.widget.presenter!.orderConfirmationView =
                                  this;
                              CustomerUtils.getCustomer().then((customer) {
                                widget.customer = customer;
                                // launch request for retrieving the delivery prices and so on.
                                if (_selectedAddress != null) {
                                  widget.presenter!.computeBilling(
                                      widget.restaurant!,
                                      widget.customer!,
                                      widget.foods!,
                                      _selectedAddress!,
                                      _selectedVoucher!,
                                      _usePoint);
                                  showLoading(true);
                                  Future.delayed(Duration(seconds: 1), () {
                                    Scrollable.ensureVisible(
                                        poweredByKey.currentContext!);
                                  });
                                }
                              });
                            }),
                      ),
                    ),
                  )),
            ],
          ),
          _buildEligibleVoucher(_orderBillConfiguration.eligible_vouchers)
        ],
      );
    }
  }

  _getFoodsIdArray(Map<ShopProductModel, int> foods) {
    List<int> foodsId = [];
    foods.forEach((foodItem, quantity) => {foodsId.add(foodItem.id!)});
    return foodsId;
  }

  @override
  void sorryDemoAccountAlert() {
    // show alert for demo-account saying how you can't order

    _showDialog(
      asset_png: ImageAssets.demo_icon, // untrustful
      message:
          "${AppLocalizations.of(context)!.translate('demo_account_alert')}",
      isYesOrNo: false,
    );
  }

  _buildPointDiscountOption() {
    if (_orderBillConfiguration == null ||
            _orderBillConfiguration!.kaba_point?.balance == null ||
            _orderBillConfiguration!.kaba_point?.is_eligible == false ||
            _isPreorderSelected()
        // or if preorder
        ) return Container();

    /* before we build the bill, we must know how much can you reduce your bill with*/

    return Container(
      decoration: BoxDecoration(
          color: KColors.new_gray,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          /* discount points available*/
          InkWell(
              splashColor: Colors.white,
              child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 20),
                              Text(
                                  "${AppLocalizations.of(context)!.translate('discount_point_available')}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: KColors.new_black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  child: Text(
                                      "${_orderBillConfiguration!.kaba_point?.can_use_amount}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: KColors.primaryColor))),
                              SizedBox(width: 20),
                            ],
                          ),
                        )
                      ])),
              onTap: () {
                // _pickDeliveryAddress();
              }),
          SizedBox(height: 10),
          Container(
            child: Text(
                "${AppLocalizations.of(context)!.translate(_orderBillConfiguration.kaba_point!.is_eligible! ? (_orderBillConfiguration.kaba_point!.can_be_used! ? 'use_of_kaba_points' : 'kaba_points_monthly_limit_reached') : 'use_of_kaba_points_not_eligible')}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: !_orderBillConfiguration.kaba_point!.can_be_used! &&
                            _orderBillConfiguration.kaba_point!.is_eligible!
                        ? CommandStateColor.delivered
                        : Colors.grey)),
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
          SizedBox(height: 10),
          // appears only if you are eligible
          _orderBillConfiguration.kaba_point!.is_eligible!
              ? (_orderBillConfiguration.kaba_point!.can_be_used!
                  ? InkWell(
                      splashColor: Colors.white,
                      child: Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Row(children: <Widget>[
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                RichText(
                                    text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            "${AppLocalizations.of(context)!.translate('use_delivery_point')}",
                                        style: TextStyle(
                                            color: KColors.new_black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            "${_orderBillConfiguration!.kaba_point?.amount_to_reduce}",
                                        style: TextStyle(
                                            color: KColors.primaryColor,
                                            fontWeight: FontWeight.bold))
                                  ],
                                )),
                              ],
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FlutterSwitch(
                                  disabled: isConnecting,
                                  activeColor: KColors.primaryColor,
                                  inactiveColor: Colors.grey,
                                  width: 52.0,
                                  height: 28.0,
                                  valueFontSize: 9.0,
                                  toggleSize: 20.0,
                                  value: _usePoint,
                                  borderRadius: 12.0,
                                  padding: 2.5,
                                  showOnOff: true,
                                  activeText:
                                      "${AppLocalizations.of(context)!.translate('yes')}",
                                  inactiveText:
                                      "${AppLocalizations.of(context)!.translate('no')}",
                                  onToggle: (val) {
                                    setState(() {
                                      _usePoint = val;
                                    });

                                    if (_usePoint && _selectedVoucher != null) {
                                      // keep the old voucher
                                      _oldSelectedVoucher = _selectedVoucher;
                                      _selectedVoucher = null;
                                    } else if (!_usePoint &&
                                        _oldSelectedVoucher != null) {
                                      _selectedVoucher = _oldSelectedVoucher;
                                    }

                                    // according to what is there we can enable or disable
                                    CustomerUtils.getCustomer()
                                        .then((customer) {
                                      widget.customer = customer;
                                      widget.presenter!.computeBilling(
                                          widget.restaurant!,
                                          widget.customer!,
                                          widget.foods!,
                                          _selectedAddress!,
                                          _selectedVoucher!,
                                          _usePoint);
                                      Future.delayed(Duration(seconds: 1), () {
                                        Scrollable.ensureVisible(
                                            poweredByKey.currentContext!);
                                      });
                                      showLoading(true);
                                      //   Timer(Duration(milliseconds: 100), () => _listController.jumpTo(_listController.position.maxScrollExtent));
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        Scrollable.ensureVisible(
                                            poweredByKey.currentContext!);
                                      });
                                    });
                                  },
                                ),
                                SizedBox(width: 20)
                              ],
                            ),
                          ),
                        ]),
                      ))
                  : Container())
              : Container(),
        ],
      ),
    );
  }
}
