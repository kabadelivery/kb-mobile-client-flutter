import 'dart:async';

import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/DeliveryTimeFrameModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/_static_data/NetworkImages.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
//import 'package:vibration/vibration.dart';
//import 'package:audioplayers/audioplayers.dart';


class OrderConfirmationPage2 extends StatefulWidget {

  static var routeName = "/OrderConfirmationPage2";

  Map<RestaurantFoodModel, int> addons, foods;

//  int totalPrice;

  OrderConfirmationPresenter presenter;

  CustomerModel customer;

  int orderOrPreorderChoice = 0;

  RestaurantModel restaurant;

  int orderTimeRangeSelected = 0;


  OrderConfirmationPage2({Key key, this.presenter, this.foods, this.addons, this.restaurant}) : super(key: key);

  @override
  _OrderConfirmationPage2State createState() => _OrderConfirmationPage2State();
}

class _OrderConfirmationPage2State extends State<OrderConfirmationPage2> implements OrderConfirmationView {

  DeliveryAddressModel _selectedAddress;

  /* pricing configuration */
  OrderBillConfiguration _orderBillConfiguration = OrderBillConfiguration();

  bool isConnecting = false;
  bool isPayAtDeliveryLoading = false;
  bool isPreorderLoading = false;
  bool isPayNowLoading = false;

  bool checkIsRestaurantOpenConfigIsLoading = true;

  TextEditingController _addInfoController;

  bool _checkOpenStateError = false;

  ScrollController _listController;

  _OrderConfirmationPage2State();

  List<String> dayz = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listController = new ScrollController();
    _addInfoController = new TextEditingController();
    this.widget.presenter.orderConfirmationView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // check opening state of the restaurant
      widget.presenter.checkOpeningStateOf(customer, widget.restaurant);
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    dayz = [
      "${AppLocalizations.of(context).translate('monday_long')}",
      "${AppLocalizations.of(context).translate('tuesday_long')}",
      "${AppLocalizations.of(context).translate('wednesday_long')}",
      "${AppLocalizations.of(context).translate('thursday_long')}",
      "${AppLocalizations.of(context).translate('friday_long')}",
      "${AppLocalizations.of(context).translate('saturday_long')}",
      "${AppLocalizations.of(context).translate('sunday_long')}",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                }),
            backgroundColor: KColors.primaryYellowColor,
            title: Text("${AppLocalizations.of(context).translate('confirm_order')}")
        ),
        // check if the restaurant is open before showing anything.
        body:
        (isPayAtDeliveryLoading == true || isPayNowLoading == true || isPreorderLoading == true) ?
        Container(height: MediaQuery.of(context).size.height,
          child: Center(child:Container(padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: <Widget>[
              // loading page.
              SizedBox(child: CircularProgressIndicator(), height: 80, width: 80),
              SizedBox(height: 30),
              Text("${AppLocalizations.of(context).translate('processing_payment')}", textAlign: TextAlign.center,)
            ]),
          )),
        ):
        (checkIsRestaurantOpenConfigIsLoading ? Center(child: CircularProgressIndicator())
            :  (_checkOpenStateError || (_orderBillConfiguration!= null && _orderBillConfiguration.open_type>= 0 && _orderBillConfiguration.open_type <=3)  ? _buildOrderConfirmationPage2()
            : ErrorPage(onClickAction: ()=>  widget.presenter.checkOpeningStateOf(widget.customer, widget.restaurant))))
    );
  }

  Future _pickDeliveryAddress() async {
    setState(() {
//      _orderBillConfiguration = null;
      _orderBillConfiguration.isBillBuilt = false;
      _selectedAddress = null;
    });

    /* jump and get it */
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAddressesPage(pick: true, presenter: AddressPresenter()),
      ),
    );

    if (results != null && results.containsKey('selection')) {
      setState(() {
        _selectedAddress = results['selection'];
      });
      // launch request for retrieving the delivery prices and so on.
      widget.presenter.computeBilling(widget.restaurant,widget.customer, widget.foods, _selectedAddress);
      showLoading(true);
      Timer(Duration(milliseconds: 100), () => _listController.jumpTo(_listController.position.maxScrollExtent));
    }
  }


  _buildAddress(DeliveryAddressModel selectedAddress) {
    if (selectedAddress == null)
      return Container();
    else
      return Container(color: Colors.white, padding: EdgeInsets.all(10),
        child: Column(
            children: <Widget>[
              Container(width: MediaQuery
                  .of(context)
                  .size
                  .width, child:
              Text(selectedAddress.name, textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
              ),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Expanded(child: Text(
                    selectedAddress.description, textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black.withAlpha(200)))),
                IconButton(icon: Icon(
                    Icons.delete_forever, color: KColors.primaryColor),
                    onPressed: () {})
              ])
            ]
        ),
      );
  }

  _buildBill() {
    if (_orderBillConfiguration == null)
      return Container();

    if (_isPreorderSelected()) {
      return Card(margin: EdgeInsets.only(left: 10, right: 10),
          child: Container(padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              NetworkImages.kaba_promotion_gif))
                      )
                  )
              ),
              Container(),
              /* content */
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('order_amount')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* check if there is promotion on Commande */
                    Row(
                      children: <Widget>[
                        /* montant commande normal */
                        Text("${_orderBillConfiguration?.command_pricing} ${AppLocalizations.of(context).translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('delivery_amount')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* check if there is promotion on Livraison */
                    Row(
                      children: <Widget>[
                        /* montant livraison normal */
                        Text("${_orderBillConfiguration?.shipping_pricing} ${AppLocalizations.of(context).translate('currency')}", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Center(child: Container(width: MediaQuery
                  .of(context)
                  .size
                  .width - 10, color: Colors.black, height: 1)),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('net_price')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* montant total a payer */
                    Text("${_orderBillConfiguration?.total_normal_pricing} F",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: KColors.primaryColor,
                            fontSize: 18)),
                  ]),
              SizedBox(height: 10),
              (Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              NetworkImages.kaba_promotion_gif))
                      )
                  )
              )),
            ]),
          ));
    } else
      return Card(margin: EdgeInsets.only(left: 10, right: 10),
          child: Container(padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[
//                      SizedBox(height: 10),
//                      NetworkImages.kaba_promotion_gif
              (_orderBillConfiguration?.remise > 0 &&
                  !_isPreorder()
                  ? Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(
                              NetworkImages.kaba_promotion_gif))
                      )
                  )
              ) : Container()),
              Container(),
              /* content */
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('order_amount')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* check if there is promotion on Commande */
                    Row(
                      children: <Widget>[
                        /* montant commande normal */
                        Text(_orderBillConfiguration?.command_pricing >
                            _orderBillConfiguration?.promotion_pricing
                            ? "(${_orderBillConfiguration?.command_pricing})"
                            : "", style: TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15)),
                        SizedBox(width: 5),
                        /* montant commande promotion */
                        Text(_orderBillConfiguration?.command_pricing >
                            _orderBillConfiguration?.promotion_pricing
                            ? "${_orderBillConfiguration?.promotion_pricing} ${AppLocalizations.of(context).translate('currency')}"
                            : "${_orderBillConfiguration?.command_pricing} ${AppLocalizations.of(context).translate('currency')}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('delivery_amount')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* check if there is promotion on Livraison */
                    Row(
                      children: <Widget>[
                        /* montant livraison normal */
                        Text(
                            _orderBillConfiguration?.shipping_pricing >
                                _orderBillConfiguration
                                    ?.promotion_shipping_pricing
                                ? "(${_orderBillConfiguration?.shipping_pricing})"
                                : "", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15)),
                        SizedBox(width: 5),
                        /* montant livraison promotion */
                        Text(
                            _orderBillConfiguration?.shipping_pricing >
                                _orderBillConfiguration
                                    ?.promotion_shipping_pricing
                                ? "${_orderBillConfiguration
                                ?.promotion_shipping_pricing} ${AppLocalizations.of(context).translate('currency')}"
                                : "${_orderBillConfiguration
                                ?.shipping_pricing} ${AppLocalizations.of(context).translate('currency')}", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    )
                  ]),
              SizedBox(height: 10),
              _orderBillConfiguration?.remise > 0 ?
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Text("${AppLocalizations.of(context).translate('discount')}", style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.grey)),
                    /* montrer le discount s'il y'a lieu */
                    Text("-${_orderBillConfiguration?.remise}%", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: CommandStateColor.delivered)),
                  ]) : Container(),
              SizedBox(height: 10),
              Center(child: Container(width: MediaQuery
                  .of(context)
                  .size
                  .width - 10, color: Colors.black, height: 1)),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('net_price')}", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    /* montant total a payer */
                    Text("${_orderBillConfiguration?.total_pricing} F",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: KColors.primaryColor,
                            fontSize: 18)),
                  ]),
              SizedBox(height: 10),
              (
                  (_orderBillConfiguration?.remise > 0 &&
                      !_isPreorder())
                      ? Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(Utils.inflateLink(
                                  NetworkImages.kaba_promotion_gif))
                          )
                      )
                  ) : Container()),
            ]),
          ));
  }

  _cookingTimeEstimation() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("${AppLocalizations.of(context).translate('cooking_time_estimation')}", style: TextStyle(fontSize: 16)),
              Text("30 min",
                  style: TextStyle(color: KColors.primaryColor, fontSize: 18))
            ]));
  }

  _buildRestaurantCoupon() {
    return Stack(children: <Widget>[
      Positioned(left: 10,
          bottom: 10,
          child: Icon(
              Icons.fastfood, size: 40, color: Colors.white.withAlpha(50))),
//      Center(child: Icon(Icons.add_circle, color: Colors.white)),
      Center(child: Text(
          "-5000", style: TextStyle(fontSize: 40, color: Colors.white)),)
    ]);
  }

  _buildDeliveryCoupon() {
    return Stack(children: <Widget>[
      Positioned(left: 10,
          bottom: 10,
          child: Icon(Icons.directions_bike, size: 40,
              color: Colors.white.withAlpha(50))),
//      Center(child: Icon(Icons.add_circle, color: Colors.white)),
      Center(child: Text(
          "-50%", style: TextStyle(fontSize: 40, color: Colors.white)),)
    ]);
  }

  Widget _buildOrderConfirmationPage2() {

    /* we get this one ... then we tend to select and address to end the purchase. */

    return SingleChildScrollView(
      controller: _listController,
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10)]
            ..addAll(
                _buildFoodList()
            )
          // restaurant is closed and we can't do nothing
            ..addAll( (_orderBillConfiguration.hasCheckedOpen == true && _orderBillConfiguration.can_preorder == 0 && _orderBillConfiguration.open_type != 1) ? <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(margin: EdgeInsets.only(top:40, right: 20, left:20), decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(10), child: Text("Sorry,the restaurant is closed right now. Please come back later or contact our Customer Care. \nThank you", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
                  SizedBox(height:10),
                  SizedBox(
                      height: 120,
                      child:SvgPicture.asset(
                        VectorsData.closed_shop_svg,
                      ))
                ],
              )
            ] :
            <Widget>[
              SizedBox(height: 10),
              _buildRadioPreorderChoice(),
              SizedBox(height: 10),
              Container(
                  child: (widget.orderOrPreorderChoice == 1 && _orderBillConfiguration.open_type == 1 && _orderBillConfiguration.can_preorder == 1 ) || (_orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type != 1 && widget.orderOrPreorderChoice == 0) ?
                  _buildDeliveryTimeFrameList() : Container(), color: Colors.white),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                color: Colors.white,
                child: TextField(controller: _addInfoController, maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "${AppLocalizations.of(context).translate('additional_info')}",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 5),
              _cookingTimeEstimation(),
              SizedBox(height: 10),
              InkWell(
                  splashColor: Colors.white,
                  child: Container(padding: EdgeInsets.only(top: 5, bottom: 5),
                      color: KColors.primaryColor,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text("${AppLocalizations.of(context).translate('choose_delivery_address')}",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            Row(children: <Widget>[
                              IconButton(icon: Icon(Icons.my_location,
                                  color: Colors.white), onPressed: null),
                            ])
                          ])), onTap: () {
                _pickDeliveryAddress();
              }
              ),
              SizedBox(height: 10),
              _buildAddress(_selectedAddress),
              SizedBox(height: 25),
              isConnecting
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
              SizedBox(height: 20),
              _orderBillConfiguration != null && _orderBillConfiguration?.isBillBuilt == true ?
              // check if out of range before doing anything.
              _orderBillConfiguration?.out_of_range == true ? _buildOutOfRangePage() :
              (Column(children: <Widget>[
                _buildBill(),
                SizedBox(height: 10),
                Container(width: MediaQuery
                    .of(context)
                    .size
                    .width,
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("${AppLocalizations.of(context).translate('your_balance')}", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 10),
                          Text("${AppLocalizations.of(context).translate('currency')} ${StateContainer.of(context).balance == null ? "---" : StateContainer.of(context).balance}",
                              style: TextStyle(color: KColors.primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                      RaisedButton(child: Text("${AppLocalizations.of(context).translate('top_up')}",style: TextStyle(color: Colors.white)), color: KColors.primaryColor, onPressed: ()=>_topUpAccount()),
                    ],
                  ),
                ),
                _isPreorderSelected() ?   SizedBox(height: 10) : Container(),
                // purchase buttons are becoming cards.
                _isPreorderSelected() ?   _buildPreOrderButton() : Container(),
                !_isPreorderSelected() ? SizedBox(height: 10) : Container(),
                !_isPreorderSelected() ? _buildOrderNowButton() : Container(),
                !_isPreorderSelected() ? SizedBox(height: 10) : Container(),
                !_isPreorderSelected() ? _buildOrderPayAtArrivalButton() : Container(),
                SizedBox(height: 30),
              ])) : Container(),
            ])
      ),
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
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  @override
  void systemError() {
    showLoading(false);
    setState(() {
      checkIsRestaurantOpenConfigIsLoading = false;
    });
    mToast("${AppLocalizations.of(context).translate('system_error')}");
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
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void inflateBillingConfiguration(OrderBillConfiguration configuration) {
    setState(() {
      _orderBillConfiguration = configuration;
    });
    showLoading(false);
  }

  _buildPurchaseButtonsOld() {
    if (_orderBillConfiguration == null)
      return Container();

    return Column(children: <Widget>[
      // pay at arrival button
      _orderBillConfiguration?.pay_at_delivery
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
                  Text("${AppLocalizations.of(context).translate('pay_at_delivery')}", style: TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              onPressed: () {}),
        ],
      )
          : Container(child: Text("${AppLocalizations.of(context).translate('cant_pay_at_delivery')}")),
      SizedBox(height: 20),
      // pay immediately button
      _orderBillConfiguration?.account_balance != null &&
          _orderBillConfiguration.prepayed &&
          _orderBillConfiguration?.account_balance >
              _orderBillConfiguration?.total_pricing ?
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
                  Text("${AppLocalizations.of(context).translate('pay_now')}", style: TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              onPressed: _payNow()),
        ],
      ) : Container(child: Text(
        "${AppLocalizations.of(context).translate('cant_prepay_balance_insufficient')}",
        style: TextStyle(fontSize: 16,
            color: KColors.primaryColor,
            fontWeight: FontWeight.bold),)),
      SizedBox(height: 50)
    ]);
  }


  _buildPurchaseButtons() {
    return Column(children: <Widget>[
      SizedBox(height: 10),
      /* your account balance is */
      Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: RichText(
              text: TextSpan(
                  text: '${AppLocalizations.of(context).translate('your_balance_is')} ',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(text: "${Utils.inflatePrice(
                        "${_orderBillConfiguration?.account_balance}")} ${AppLocalizations.of(context).translate('currency')}",
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
      /* is your balance sufficient for the purchase ?*/
      _orderBillConfiguration?.account_balance != null &&
          _orderBillConfiguration.prepayed &&
          _orderBillConfiguration?.account_balance >
              _orderBillConfiguration?.total_pricing ?
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
                  Text("${AppLocalizations.of(context).translate('pay_now')}", style: TextStyle(color: Colors.white,
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
      ) : (!_orderBillConfiguration.prepayed ?
      Container(margin: EdgeInsets.only(left: 20, right: 20),
          child: Text(
              "${AppLocalizations.of(context).translate('restaurant_no_allow_prepay')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold)))
          : Container(child: Text(
          "${AppLocalizations.of(context).translate('balance_insufficient')}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14,
              color: KColors.primaryColor,
              fontWeight: FontWeight.bold)))),
      SizedBox(height: 20),
      /* check if you can post pay */
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
                      Text("${AppLocalizations.of(context).translate('pay_at_delivery')}", style: TextStyle(
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
                  "${AppLocalizations.of(context).translate('cant_pay_at_delivery_max_pay_reached')} (${_orderBillConfiguration
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
              "${AppLocalizations.of(context).translate('cant_pay_because_ongoing_order')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.mBlue,
                  fontWeight: FontWeight.normal))) :
      (!_orderBillConfiguration.pay_at_delivery ?
      Container(margin: EdgeInsets.only(left: 20, right: 20),
          child: Text("${AppLocalizations.of(context).translate('restaurant_no_allow_pay_at_delivery')}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: KColors.mBlue,
                  fontWeight: FontWeight.normal)))
          : Container())),
      SizedBox(height: 30),
    ]);
  }

  _payNow() async {
    // 1. get password
    var results = await Navigator.of(context).push(
        new MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              return RetrievePasswordPage(type: 3);
            }
        ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context).translate('wrong_code')}");
      } else {
        String _mCode = results['code'];
        showLoadingPreorder(true);
        if (Utils.isCode(_mCode)) {
          widget.presenter.payNow(
              widget.customer, widget.foods, _selectedAddress, _mCode,
              _addInfoController.text);
        } else {
          mToast("${AppLocalizations.of(context).translate('wrong_code')}");
        }
      }
    }
//    _playMusicForSuccess();
  }

  _payAtDelivery(bool isDialogShown) async {

    // if untrustful, you can't go further.
    if (_orderBillConfiguration?.trustful == 0) {
      _showDialog(
        iccon: VectorsData.questions, // untrustful
        message: "${AppLocalizations.of(context).translate('sorry_ongoing_order')}",
        isYesOrNo: false,
      );
      return;
    }

    if (!isDialogShown) {
      _showDialog(
          iccon: VectorsData.questions,
          message: "${AppLocalizations.of(context).translate('prevent_pay_at_delivery')}",
          isYesOrNo: true,
          actionIfYes: () => _payAtDelivery(true)
      );
      return;
    }

    // 1. get password
    var results = await Navigator.of(context).push(
        new MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              return RetrievePasswordPage(type: 3);
            }
        ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context).translate('wrong_code')}");
      } else {
        String _mCode = results['code'];
        showLoadingPayAtDelivery(true);
        if (Utils.isCode(_mCode)) {
          widget.presenter.payAtDelivery(
              widget.customer, widget.foods, _selectedAddress, _mCode,
              _addInfoController.text);
        } else {
          mToast("${AppLocalizations.of(context).translate('wrong_code')}");
        }
      }
    }
  }


  _payPreorder(bool isDialogShown) async {

    DeliveryTimeFrameModel selectedFrame;

    // if there is no choosen timerange then error with toast
    if (widget.orderTimeRangeSelected >= 0 && widget.orderTimeRangeSelected < _orderBillConfiguration.deliveryFrames?.length)
      selectedFrame = _orderBillConfiguration.deliveryFrames[widget.orderTimeRangeSelected];
    else {
      _showDialog(icon: Icon(Icons.error), message: "${AppLocalizations.of(context).translate('choose_delivery_frame')}");
      return;
    }

    if (!isDialogShown) {
      _showDialog(
          iccon: VectorsData.questions,
          message: "${AppLocalizations.of(context).translate('food_will_be_delivered_on')} ${Utils.timeStampToDayDate(selectedFrame.start, dayz:dayz)} between ${Utils.timeStampToHourMinute(selectedFrame.start)} and ${Utils.timeStampToHourMinute(selectedFrame.end)}",
          isYesOrNo: true,
          actionIfYes: () => _payPreorder(true)
      );
      return;
    }

    // 1. get password
    var results = await Navigator.of(context).push(
        new MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              return RetrievePasswordPage(type: 3);
            }
        ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') &&
        results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("${AppLocalizations.of(context).translate('wrong_code')}");
      } else {
        String _mCode = results['code'];
        showLoadingPayAtDelivery(true);
        if (Utils.isCode(_mCode)) {
          widget.presenter.payPreorder(
              widget.customer, widget.foods, _selectedAddress, _mCode,
              _addInfoController.text, selectedFrame.start, selectedFrame.end);
        } else {
          mToast("${AppLocalizations.of(context).translate('wrong_code')}");
        }
      }
    }
  }


  void _showDialog(
      {String iccon, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        iccon,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text(
                    "OK", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  if (!okBackToHome) {
                    Navigator.of(context).pop();
                  }
                  else {
                    StateContainer.of(context).updateTabPosition(tabPosition: 2);
                    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()), (
                        r) => false);
                  }
                },
              ),
            ]
        );
      },
    );
  }

  void showPayNowLoading(bool isLoading) {
    /* and hide all the other buttons. */
    setState(() {
      isPayNowLoading = isLoading;
    });
  }

  void showLoadingPayAtDelivery (bool isLoading) {
    setState(() {
      isPayAtDeliveryLoading = isLoading;
    });
  }

  void showLoadingPreorder (bool isLoading) {
    setState(() {
      isPreorderLoading = isLoading;
    });
  }

  Future<void> _playMusicForSuccess() async {
    // play music
    AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    audioPlayer.setVolume(1.0);
    AudioPlayer.logEnabled = true;
    var audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.play(MusicData.command_success_hold_on);
    if (await Vibration.hasVibrator()
    ) {
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
      _showOrderSuccessDialog();
    } else {

      String message = "";
      switch (errorCode) {
        case 300:
          message = "${AppLocalizations.of(context).translate('300_wrong_password')}";
          break;
        case 301: // restaurant doesnt exist
          message = "${AppLocalizations.of(context).translate('301_server_issue')}";
          break;
        case 302:
          message = "${AppLocalizations.of(context).translate('302_unable_pay_at_arrival')}";
          break;
        case 303:
          message = "${AppLocalizations.of(context).translate('303_unable_online_payment')}";
          break;
        case 304:
          message = "${AppLocalizations.of(context).translate('304_address_error')}";
          break;
        case 305:
          message = "${AppLocalizations.of(context).translate('305_308_balance_insufficient')}";
          break;
        case 306:
          message = "${AppLocalizations.of(context).translate('306_account_error')}";
          break;
        case 307:
          message = "${AppLocalizations.of(context).translate('307_unable_preorder')}";
          break;
        case 308:
          message = "${AppLocalizations.of(context).translate('305_308_balance_insufficient')}";
          break;
        default:
          message =
          "${AppLocalizations.of(context).translate('309_system_error')}";
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
      icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black),
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
      message: "${AppLocalizations.of(context).translate('order_congratz_praise')}",
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
          _orderBillConfiguration.open_type == 0 ? Container(decoration: BoxDecoration(color: KColors.mBlue, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(10), child: Text("Sorry,the restaurant is closed right now.\nPlease try Pre-Ordering.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))) : Container(),
          _orderBillConfiguration.open_type == 1 ?  Row(children: <Widget>[
            Radio(value: 0,
                groupValue: widget.orderOrPreorderChoice,
                onChanged: _handleOrderTypeRadioValueChange),
            Expanded(child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text("${AppLocalizations.of(context).translate('order_get_delivered_now_hint')}", style: TextStyle(
                    color: widget.orderOrPreorderChoice == 0 ? KColors
                        .primaryColor : Colors.black,
                    fontSize: widget.orderOrPreorderChoice == 0 ? 16 : 14)))),
          ]) : Container(),

          SizedBox(height: 10),
          _orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type == 1 ?
          Row(children: <Widget>[
            Radio(value: 1,
                groupValue: widget.orderOrPreorderChoice,
                onChanged: _handleOrderTypeRadioValueChange),
            Expanded(child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                    "${AppLocalizations.of(context).translate('preorder_now_hint')}",
                    style: TextStyle(
                        color: widget.orderOrPreorderChoice == 1 ? KColors
                            .primaryColor : Colors.black,
                        fontSize: widget.orderOrPreorderChoice == 1
                            ? 16
                            : 14)))),
          ]) : (_orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type != 1 ?
          Row(children: <Widget>[
            Radio(value: 0,
                groupValue: widget.orderOrPreorderChoice,
                onChanged: _handleOrderTypeRadioValueChange),
            Expanded(child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                    "${AppLocalizations.of(context).translate('preorder_now_hint')}",
                    style: TextStyle(
                        color: widget.orderOrPreorderChoice == 1 ? KColors
                            .primaryColor : Colors.black,
                        fontSize: widget.orderOrPreorderChoice == 1
                            ? 16
                            : 14)))),
          ]) : Container()
          )
        ],
      ),
    );
  }

  /* pre order button */
  _buildPreOrderButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: ()=>_payPreorder(false),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.access_time),
                  SizedBox(width: 5),
                  Text("${AppLocalizations.of(context).translate('confirm_preorder')}", style: TextStyle(fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text("${AppLocalizations.of(context).translate('delivery_discount')} (-${_orderBillConfiguration.discount}%)",
                  style: TextStyle(fontSize: 16, color: KColors.primaryColor)),
              SizedBox(height: 10),
              Container(child: Text(
                  "${AppLocalizations.of(context).translate('preorder_desc')}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                margin: EdgeInsets.only(left: 10, right: 10),),
              SizedBox(height: 10),
              Text("${_orderBillConfiguration.total_preorder_pricing} F", style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: KColors.primaryYellowColor)),
            ]),
          ),
        ),
      ),
    );
  }


  /* order and pay now */
  _buildOrderNowButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(onTap: ()=> _payNow(),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.moneyBill, color: hexToColor("#85bb65")),
                  SizedBox(width: 10),
                  Text("${AppLocalizations.of(context).translate('pay_now')}", style: TextStyle(fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Container(child: Text(
                  "${AppLocalizations.of(context).translate('pay_with_kaba_balance')}", textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                margin: EdgeInsets.only(left: 10, right: 10),),
              SizedBox(height: 10),
              Text("${_orderBillConfiguration.total_pricing}",
                  style: TextStyle(fontSize: 18, color: KColors.primaryColor)),
            ]),
          ),
        ),
      ),
    );
  }


  /* order and pay at arrival */
  _buildOrderPayAtArrivalButton() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(onTap: ()=>_payAtDelivery(false),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.directions_bike),
                  SizedBox(width: 5),
                  Text("${AppLocalizations.of(context).translate('pay_at_arrival')}", style: TextStyle(fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Container(child: Text(
                  "${AppLocalizations.of(context).translate('pay_with_cash_at_delivery')}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                margin: EdgeInsets.only(left: 10, right: 10),),
              SizedBox(height: 10),
              Text("${_orderBillConfiguration.total_pricing}",
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ]),
          ),
        ),
      ),
    );
  }


  void _handleOrderTypeRadioValueChange(int value) {
    setState(() {
      widget.orderOrPreorderChoice = value;
    });
  }

  _buildDeliveryTimeFrameList() {

    if (_orderBillConfiguration== null || _orderBillConfiguration.deliveryFrames == null)
      return Container();

    return Column(
        children: <Widget>[
        ]..addAll(List.generate(_orderBillConfiguration.deliveryFrames?.length, (index) {
          return Container(
              margin: const EdgeInsets.only(top: 8.0, bottom: 8, left: 16, right: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // left date, time,
                  // right checkbox
                  Row(children: <Widget>[
                    Container(child: Text("${Utils.timeStampToDayDate(_orderBillConfiguration.deliveryFrames[index].start)}", style: TextStyle(color: Colors.white)),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: CommandStateColor.delivered),),
                    SizedBox(width: 10),
                    Text("${Utils.timeStampToHourMinute(_orderBillConfiguration.deliveryFrames[index].start)} - ${Utils.timeStampToHourMinute(_orderBillConfiguration.deliveryFrames[index].end)}"),
                  ]),
                  Radio(value: index,
                      groupValue: widget.orderTimeRangeSelected,
                      onChanged: _timeFrameCheckBoxOnChange),
                ],
              )
          );
        })));
  }

  _timeFrameCheckBoxOnChange(value) {
    setState(() {
      widget.orderTimeRangeSelected = value;
    });
  }

  _buildFoodList() {

    List<Widget> foodList = List();
    widget.foods.forEach((k,v) {
      foodList.add(_buildBasketItem(k,v));
    });
    return foodList;
  }

  Widget _buildBasketItem(RestaurantFoodModel food, int quantity) {

    return
      Card(
          elevation: 2.0,
          margin: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          child: InkWell(
              child: Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 10),
                      leading: Stack(
                        overflow: Overflow.visible,
//                        _keyBox.keys.firstWhere(
//                        (k) => curr[k] == "${menuIndex}-${foodIndex}", orElse: () => null);
                        /* according to the position of the view, menu - food, we have a key that we store. */
                        children: <Widget>[
                          Container(
                            height: 50, width: 50,
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: KColors.primaryYellowColor,
                                    width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(Utils
                                        .inflateLink(food.pic))
                                )
                            ),
                          ),
                        ],
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${food?.name?.toUpperCase()}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Row(children: <Widget>[
                                Text("${food?.price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        decoration: food.promotion != 0
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: KColors.primaryYellowColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal)),
                                SizedBox(width: 5),
                                (food.promotion != 0 ? Text(
                                    "${food?.promotion_price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal))
                                    : Container()),
                                SizedBox(width: 5),

                                Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryYellowColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal)),
                                SizedBox(width: 10,),
                                Text(" X ${quantity}", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // add-up the buttons at the right side of it
                    Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.transparent),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
          )
      );

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
    });
  }

  @override
  void inflateBillingConfiguration1(OrderBillConfiguration configuration) {
    setState(() {
      _orderBillConfiguration = configuration;
      _orderBillConfiguration.hasCheckedOpen = true;
    });
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

    _orderBillConfiguration.shipping_pricing = configuration.shipping_pricing;
    _orderBillConfiguration.command_pricing = configuration.command_pricing;
    _orderBillConfiguration.promotion_pricing = configuration.promotion_pricing;
    _orderBillConfiguration.promotion_shipping_pricing = configuration.promotion_shipping_pricing;
    _orderBillConfiguration.total_normal_pricing = configuration.total_normal_pricing;
    _orderBillConfiguration.total_pricing = configuration.total_pricing;
    _orderBillConfiguration.remise = configuration.remise;

    _orderBillConfiguration.total_preorder_pricing = (configuration.command_pricing.toDouble()+((100-int.parse(_orderBillConfiguration.discount).toDouble())*configuration.shipping_pricing.toDouble()/100)).toInt();

    setState(() {
      _orderBillConfiguration.isBillBuilt = true;
    });
    Timer(Duration(milliseconds: 1000), () => _listController.jumpTo(_listController.position.maxScrollExtent));
  }

  @override
  void isRestaurantOpenConfigLoading(bool isLoading) {

    setState(() {
      _checkOpenStateError = false;
      checkIsRestaurantOpenConfigIsLoading = isLoading;
    });
  }

  _isPreorderSelected() {
    if ((_orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type == 1) && widget.orderOrPreorderChoice == 1)
      return true;
    if ((_orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type != 1) && widget.orderOrPreorderChoice == 0)
      return true;
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
    return  ((widget.orderOrPreorderChoice == 1 && _orderBillConfiguration.open_type == 1 && _orderBillConfiguration.can_preorder == 1 ) || (_orderBillConfiguration.can_preorder == 1 && _orderBillConfiguration.open_type != 1 && widget.orderOrPreorderChoice == 0));
  }

  _buildOutOfRangePage() {
    return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(margin: EdgeInsets.only(top:20, right: 20, left:20), decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(10), child: Text("${AppLocalizations.of(context).translate('out_of_delivery_range')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
        SizedBox(height:10),
        SizedBox(
            height: 120,
            child:SvgPicture.asset(
              VectorsData.out_of_range,
            )),
        SizedBox(height:30),
      ],
    );
  }

  _topUpAccount() async {

    // jump to topup page.
    var results = await Navigator.of(context).push(
        new MaterialPageRoute<dynamic>(
            builder: (BuildContext context) {
              return TopUpPage(presenter: TopUpPresenter());
            }
        ));

    if (results != null && results.containsKey('check_balance')) {

//      bool check_balance =  results['check_balance'];
      String link = results['link'];
      if (results['check_balance'] == true) {
        // show a dialog that tells the user to check his balance after he has topup up.
        link = Uri.encodeFull(link);
        _launchURL(link);
        _showDialog_(message: "${AppLocalizations.of(context).translate('please_check_balance')}", svgIcon: VectorsData.account_balance);
      }
    }
  }


  Future<dynamic> _showDialog_(
      {String svgIcon, var message,}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                          svgIcon
                      )),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions: <Widget>[
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter()));
                },
              ),
            ]
        );
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
        print(_);
      }
    }
    return -1;
  }

  void _jumpToPage (BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

}
