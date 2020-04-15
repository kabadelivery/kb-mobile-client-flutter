import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/contracts/order_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/MusicData.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';
//import 'package:vibration/vibration.dart';
//import 'package:audioplayers/audioplayers.dart';


class OrderConfirmationPage2 extends StatefulWidget {

  static var routeName = "/OrderConfirmationPage2";

  Map<RestaurantFoodModel, int> addons, foods;

  int totalPrice;

  OrderConfirmationPresenter presenter;

  CustomerModel customer;

  int orderOrPreorderChoice = 0;

  OrderConfirmationPage2({Key key, this.presenter, this.foods, this.addons, this.totalPrice = 3000}) : super(key: key);

  @override
  _OrderConfirmationPage2State createState() => _OrderConfirmationPage2State();
}

class _OrderConfirmationPage2State extends State<OrderConfirmationPage2> implements OrderConfirmationView {

  DeliveryAddressModel _selectedAddress;

  /* pricing configuration */
  OrderBillConfiguration _orderBillConfiguration = OrderBillConfiguration.fake();

//  Map<RestaurantFoodModel, int> addons, foods;

  bool isConnecting = false;
  bool isPayAtDeliveryLoading = false;
  bool isPayNowLoading = false;

  TextEditingController _addInfoController;

  _OrderConfirmationPage2State();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addInfoController = new TextEditingController();
    this.widget.presenter.orderConfirmationView = this;
    CustomerUtils.getCustomer().then((customer){
      widget.customer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar (
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {Navigator.pop(context);}),
            backgroundColor: KColors.primaryYellowColor ,
            title: Text("Confirm Order")
        ),
        body: _buildOrderConfirmationPage2()
    );
  }

  Future _pickDeliveryAddress() async {

    setState(() {
      _orderBillConfiguration = null;
      _selectedAddress = null;
    });

    /* jump and get it */
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAddressesPage(pick: true),
      ),
    );

    if (results != null && results.containsKey('selection')) {
      setState(() {
        _selectedAddress = results['selection'];
      });
      // launch request for retrieving the delivery prices and so on.
      widget.presenter.computeBilling(widget.customer, widget.foods, _selectedAddress);
      showLoading(true);
    }
  }


  _buildAddress(DeliveryAddressModel selectedAddress) {

    if (selectedAddress == null)
      return Container();
    else
      return Container(color: Colors.white, padding: EdgeInsets.all(10),
        child: Column(
            children: <Widget>[
              Container(width: MediaQuery.of(context).size.width, child:
              Text(selectedAddress.name, textAlign: TextAlign.left ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20))
              ),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Expanded(child: Text(selectedAddress.description, textAlign: TextAlign.left,style: TextStyle(color: Colors.black.withAlpha(200)))),
                IconButton(icon: Icon(Icons.delete_forever, color: KColors.primaryColor), onPressed: () {})
              ])
            ]
        ),
      );
  }

  _buildBill() {
    if (_orderBillConfiguration == null)
      return Container();
    return Card(margin: EdgeInsets.only(left: 10, right: 10),
        child: Container(padding: EdgeInsets.all(10),
          child: Column(children:<Widget>[
//                      SizedBox(height: 10),
//                      "/web/assets/app_icons/promo_large.gif"
            (int.parse(_orderBillConfiguration?.remise) > 0 ? Container (
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink("/web/assets/app_icons/promo_large.gif"))
                    )
                )
            ): Container ()),
            Container(),
            /* content */
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Montant Commande:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              /* check if there is promotion on Commande */
              Row(
                children: <Widget>[
                  Text(_orderBillConfiguration?.command_pricing > _orderBillConfiguration?.promotion_pricing ? "(${_orderBillConfiguration?.command_pricing})" : "", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                  SizedBox(width: 5),
                  Text(_orderBillConfiguration?.command_pricing > _orderBillConfiguration?.promotion_pricing ? "${_orderBillConfiguration?.promotion_pricing} FCFA" : "${_orderBillConfiguration?.command_pricing} FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Montant Livraison:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              /* check if there is promotion on Livraison */
              Row(
                children: <Widget>[
                  Text(int.parse(_orderBillConfiguration?.shipping_pricing) > int.parse(_orderBillConfiguration?.promotion_shipping_pricing) ? "(${_orderBillConfiguration?.shipping_pricing})" : "", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                  SizedBox(width: 5),
                  Text(int.parse(_orderBillConfiguration?.shipping_pricing) > int.parse(_orderBillConfiguration?.promotion_shipping_pricing) ? "${_orderBillConfiguration?.promotion_shipping_pricing} FCFA" : "${_orderBillConfiguration?.shipping_pricing} FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
            SizedBox(height: 10),
            int.parse(_orderBillConfiguration?.remise) > 0 ?
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Remise:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
              /* check if there is remise */
              Text("-${_orderBillConfiguration?.remise}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CommandStateColor.delivered)),
            ]) : Container(),
            SizedBox(height: 10),
            Center(child: Container(width: MediaQuery.of(context).size.width - 10, color: Colors.black, height:1)),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Net à Payer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("${_orderBillConfiguration?.total_pricing} F", style: TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 18)),
            ]),
            SizedBox(height: 10),
            (int.parse(_orderBillConfiguration?.remise) > 0 ? Container (
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink("/web/assets/app_icons/promo_large.gif"))
                    )
                )
            ): Container ()),
          ]),
        ));
  }

  _cookingTimeEstimation() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(top:10, bottom:10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[Text("Cooking Time estimation: ", style: TextStyle(fontSize: 16)), Text("30 min",  style: TextStyle(color: KColors.primaryColor,fontSize: 18))]));
  }

  _buildRestaurantCoupon() {
    return Stack(children: <Widget>[
      Positioned(left: 10, bottom: 10,child: Icon(Icons.fastfood, size: 40, color: Colors.white.withAlpha(50))),
//      Center(child: Icon(Icons.add_circle, color: Colors.white)),
      Center(child: Text("-5000", style: TextStyle(fontSize: 40, color: Colors.white)),)
    ]);
  }

  _buildDeliveryCoupon() {
    return Stack(children: <Widget>[
      Positioned(left: 10, bottom: 10,child: Icon(Icons.directions_bike, size: 40, color: Colors.white.withAlpha(50))),
//      Center(child: Icon(Icons.add_circle, color: Colors.white)),
      Center(child: Text("-50%", style: TextStyle(fontSize: 40, color: Colors.white)),)
    ]);
  }

  Widget _buildOrderConfirmationPage2() {

    /* we get this one ... then we tend to select and address to end the purchase. */

    return SingleChildScrollView (

      child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("Prix Commande", style: TextStyle(color: Colors.black, fontSize: 14)),
                Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                  IconButton(icon:Icon(Icons.attach_money, color: KColors.primaryColor), onPressed: () {},),
                  Text("${widget.totalPrice}F", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
                ])
              ],
            ),
            SizedBox(height: 10),
          ]
            ..addAll(<Widget>[
              SizedBox(height: 5),
              _cookingTimeEstimation(),
              SizedBox(height: 10),
              _buildRadioPreorderChoice(),
              SizedBox(height: 10),
              Container(child:  _buildDeliveryTimeFrameList(), color: Colors.white),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left:10, right: 10, top:5, bottom:5),
                color: Colors.white,
                child:TextField(controller: _addInfoController, maxLines: 3,
                    decoration: InputDecoration(labelText: "Any special request about the order ?",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              InkWell(
                  splashColor: Colors.white,
                  child:Container(padding: EdgeInsets.only(top:5,bottom: 5), color: KColors.primaryColor,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                        Text("Choisir l'adresse de Livraison", style: TextStyle(fontSize: 16,color:Colors.white)),
                        Row(children: <Widget>[
                          IconButton(icon: Icon(Icons.my_location, color: Colors.white), onPressed: null),
                        ])
                      ])), onTap: (){_pickDeliveryAddress();}
              ),
              SizedBox(height: 10),
              _buildAddress(_selectedAddress),
              SizedBox(height: 15),
              isConnecting ? Center(child: CircularProgressIndicator()) : Container(),
              SizedBox(height: 10),
              _orderBillConfiguration == null ? Container() :
              Column(children: <Widget>[
//                _buildBill(),
                Container(width: MediaQuery.of(context).size.width,
                  color:Colors.white,
                  padding: EdgeInsets.only(left: 10, right: 10, top:20, bottom:20),
                  child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Your balance:", style: TextStyle(fontSize: 17),),
                      SizedBox(width: 10),
                      Text("${_orderBillConfiguration.account_balance} XOF", style: TextStyle(color: KColors.primaryColor, fontSize: 18, fontWeight: FontWeight.normal),),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // purchase buttons are becoming cards.
                _buildPreOrderButton(),
                SizedBox(height: 10),
                _buildOrderNowButton(),
                SizedBox(height: 10),
                _buildOrderPayAtArrivalButton(),
                SizedBox(height: 30),
              ]),
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
    mToast("networkError");
  }

  @override
  void systemError() {
    showLoading(false);
    mToast("systemError");
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isConnecting = isLoading;
      if (!isLoading) {
        isPayNowLoading = false;
        isPayAtDeliveryLoading = false;
      }
    });
  }

  void mToast(String message) { Toast.show(message, context, duration: Toast.LENGTH_LONG);}

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
      _orderBillConfiguration?.pay_at_delivery ? // pay at delivery and not having ongoing delivery right now.
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)),side: BorderSide(color: Colors.transparent)),
              padding: EdgeInsets.only(top:10,bottom:10, right:10,left:10),color: KColors.mBlue, splashColor: Colors.white, child: Row(
            children: <Widget>[
              Icon(Icons.directions_bike, color: Colors.white),
              SizedBox(width: 5),
              Text("PAY AT DELIVERY", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ), onPressed: () {}) ,
        ],
      ) : Container(child: Text("you can't pay at delivery.")),
      SizedBox(height: 20),
      // pay immediately button
      _orderBillConfiguration?.account_balance!=null && _orderBillConfiguration.prepayed && _orderBillConfiguration?.account_balance > _orderBillConfiguration?.total_pricing ?
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)),side: BorderSide(color: Colors.transparent)),
              padding: EdgeInsets.only(top:10,bottom:10, right:10,left:10),
              color: KColors.primaryColor,
              splashColor: Colors.white, child:
          Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.moneyBill, color: Colors.white),
              SizedBox(width: 10),
              Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ), onPressed: _payNow()),
        ],
      ) : Container(child: Text("You can't prepay because your balance is insufficient ", style: TextStyle(fontSize: 16,color: KColors.primaryColor, fontWeight: FontWeight.bold),)),
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
                  text: 'Your balance is : ',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(text: "${Utils.inflatePrice("${_orderBillConfiguration?.account_balance}")} XOF",
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
      _orderBillConfiguration?.account_balance!=null && _orderBillConfiguration.prepayed && _orderBillConfiguration?.account_balance > _orderBillConfiguration?.total_pricing ?
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)),side: BorderSide(color: Colors.transparent)),
              padding: EdgeInsets.only(top:10,bottom:10, right:10,left:10),
              color: KColors.primaryColor,
              splashColor: Colors.white, child:
          Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.moneyBill, color: Colors.white),
              SizedBox(width: 10),
              Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              isPayNowLoading ?  Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                ],
              )  : Container(),
            ],
          ), onPressed: () => _payNow()),
        ],
      ) : (!_orderBillConfiguration.prepayed ?
      Container(margin: EdgeInsets.only(left: 20, right:20), child: Text("You can't prepay because this restaurant doesn't allow prepay.",  textAlign: TextAlign.center, style: TextStyle(fontSize: 14,color: KColors.primaryColor, fontWeight: FontWeight.bold)))
          : Container(child: Text("You can't prepay because your balance is insufficient ",  textAlign: TextAlign.center, style: TextStyle(fontSize: 14,color: KColors.primaryColor, fontWeight: FontWeight.bold)))),
      SizedBox(height: 20),
      /* check if you can post pay */
      _orderBillConfiguration.pay_at_delivery && _orderBillConfiguration.trustful ==1 ? (
          int.parse(_orderBillConfiguration.max_pay) > _orderBillConfiguration.total_pricing ?
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)),side: BorderSide(color: Colors.transparent)),
                  padding: EdgeInsets.only(top:10,bottom:10, right:10,left:10),color: KColors.mBlue, splashColor: Colors.white, child: Row(
                children: <Widget>[
                  Icon(Icons.directions_bike, color: Colors.white),
                  SizedBox(width: 5),
                  Text("PAY AT DELIVERY", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  isPayAtDeliveryLoading ?  Row(
                    children: <Widget>[
                      SizedBox(width: 10),
                      SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                    ],
                  )  : Container(),
                ],
              ), onPressed: () => _payAtDelivery(false)),
            ],
          ) :
          Container(margin: EdgeInsets.only(left: 20, right:20),
              child: Text("You can't pay at delivery because your order is more than the maximum pay at delivery amount (${_orderBillConfiguration.max_pay})",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14,color: KColors.mBlue, fontWeight: FontWeight.normal))
          )
      ) :
      (_orderBillConfiguration.trustful == 0 ?
      Container(margin: EdgeInsets.only(left: 20, right:20),child: Text("You can't pay because you already have an ungoing order. Please contact the administrator to solve this issue. \nThank you.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14,color: KColors.mBlue, fontWeight: FontWeight.normal))) :
      (!_orderBillConfiguration.pay_at_delivery ?
      Container(margin: EdgeInsets.only(left: 20, right:20),child: Text("Sorry this restaurant doesn't allow pay at delivery.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14,color: KColors.mBlue, fontWeight: FontWeight.normal)))
          : Container())),
      SizedBox(height: 30),
    ]);

  }

  _payNow() async {
//    _playMusicForSuccess();return;

    // 1. get password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return RetrievePasswordPage(type: 3);
        }
    ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') && results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("my code is not ok");
      } else {
        String _mCode = results['code'];
        showLoadingPayAtDelivery(true);
        if (Utils.isCode(_mCode)) {
          widget.presenter.payNow(
              widget.customer, widget.foods, _selectedAddress, _mCode, _addInfoController.text);
        } else {
          mToast("my code is not ok");
        }
      }
    }
    _playMusicForSuccess();

  }

  _payAtDelivery(bool isDialogShown) async {
//    _playMusicForSuccess();return;

    if (!isDialogShown) {
      _showDialog(
          icon: VectorsData.questions,
          message: "By choosing this mode, you are accepting to give the right amount of money to the delivery man.",
          isYesOrNo: true,
          actionIfYes: () => _payAtDelivery(true)
      );
      return;
    }

    // 1. get password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return RetrievePasswordPage(type: 3);
        }
    ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') && results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("my code is not ok");
      } else {
        String _mCode = results['code'];
        showLoadingPayAtDelivery(true);
        if (Utils.isCode(_mCode)) {
          widget.presenter.payAtDelivery(
              widget.customer, widget.foods, _selectedAddress, _mCode, _addInfoController.text);
        } else {
          mToast("my code is not ok");
        }
      }
    }
//    _playMusicForSuccess();
  }



  void _showDialog({var icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /* icon */
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                        icon,
//                      color: Colors.green,
                      )),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              // usually buttons at the bottom of the dialog
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("REFUSE", style: TextStyle(color:Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text("ACCEPT", style: TextStyle(color:KColors.primaryColor)),
                onPressed: (){
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text("OK", style: TextStyle(color:KColors.primaryColor)),
                onPressed: () {
                  if (!okBackToHome)
                    Navigator.of(context).pop();
                  else
                    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()), (r) => false);
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

  void showLoadingPayAtDelivery (bool isLoading){
    setState(() {
      isPayAtDeliveryLoading = isLoading;
    });
  }

  Future<void> _playMusicForSuccess() async {
    // play music
    AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    audioPlayer.setVolume(1.0);
    AudioPlayer.logEnabled = true;
    var audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.play(MusicData.command_success_hold_on);
    if (await Vibration.hasVibrator ()
    ) {
      Vibration.vibrate(duration: 500);
    }
  }

  @override
  void launchOrderSuccess(bool isSuccessful) {

    showLoadingPayAtDelivery(false);
    mToast("launcOrderSuccessfull ${isSuccessful}");
    if (isSuccessful) {  // dismiss all dialogs
      _showOrderSuccessDialog();
    } else {  // show an error or a success
      _showOrderFailureDialog();
    }
  }

  void _showOrderFailureDialog () {
    _showDialog(
      icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black),
      message: "Sorry, there is a problem with your order. Please try again.",
      isYesOrNo: false,
    );
  }

  void _showOrderSuccessDialog () {
    _playMusicForSuccess();
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.delivery_nam,
      message: "Congratulations for passing your order. Please keep your phone close to be able to check the command process.",
      isYesOrNo: false,
    );
  }

  _buildRadioPreorderChoice() {
    return  Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Radio(value: 0, groupValue: widget.orderOrPreorderChoice, onChanged: _handleOrderTypeRadioValueChange),
            Expanded(child: Container(margin:EdgeInsets.only(left:10, right:10), child: Text("Order and get delivered now", style: TextStyle(color: widget.orderOrPreorderChoice == 0 ? KColors.primaryColor : Colors.black, fontSize: widget.orderOrPreorderChoice == 0 ? 16 : 14)))),
          ]),
          SizedBox(height: 10),
          Row(children: <Widget>[
            Radio(value: 1, groupValue: widget.orderOrPreorderChoice, onChanged: _handleOrderTypeRadioValueChange),
            Expanded(child: Container(margin:EdgeInsets.only(left:10, right:10), child: Text("Pre-order and get delivered in a future time frame", style: TextStyle(color: widget.orderOrPreorderChoice == 1 ? KColors.primaryColor : Colors.black, fontSize: widget.orderOrPreorderChoice == 1 ? 16 : 14)))),
          ]),
        ],
      ),
    );
  }

  /* pre order button */
  _buildPreOrderButton() {

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.access_time),
                SizedBox(width: 5),
                Text("Confirm Pre - Order", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text("Delivery discount (-20%)", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),
            SizedBox(height: 10),
            Container(child: Text("Preorder now and get delivered at a specific time in the future", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)), margin: EdgeInsets.only(left:10, right:10),),
            SizedBox(height: 10),
            Text("(600 XOF)", style: TextStyle(fontSize: 18, color: KColors.primaryYellowColor)),
          ]),
        ),
      ),
    );
  }


  /* order and pay now */
  _buildOrderNowButton() {

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.restaurant),
                SizedBox(width: 5),
                Text("PAY NOW", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(child: Text("Pay now with your Kaba balance", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)), margin: EdgeInsets.only(left:10, right:10),),
            SizedBox(height: 10),
            Text("(600 XOF)", style: TextStyle(fontSize: 18, color: KColors.primaryColor)),
          ]),
        ),
      ),
    );
  }


  /* order and pay at arrival */
  _buildOrderPayAtArrivalButton() {

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.directions_bike),
                SizedBox(width: 5),
                Text("PAY AT ARRIVAL", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(child: Text("Pay at delivery with ca\$h to the delivery man directly", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)), margin: EdgeInsets.only(left:10, right:10),),
            SizedBox(height: 10),
            Text("(600 XOF)", style: TextStyle(fontSize: 18, color: Colors.black)),
          ]),
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
    int count = 3;

    return Container(
      margin: const EdgeInsets.only(top:8.0,bottom:8, left: 16,right:16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // left date, time,
          // right checkbox
          Row(children: <Widget>[
            Container(child: Text("Mon", style: TextStyle(color:Colors.white)),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: CommandStateColor.delivered),),
            SizedBox(width: 10),
            Text("11h30 - 12h30"),
          ]),
          Checkbox(value: true, onChanged: _timeFrameCheckBoxOnChange(), activeColor: Colors.white, checkColor: KColors.primaryColor)
        ],
      ),
    );
  }

  _timeFrameCheckBoxOnChange() {}
}
