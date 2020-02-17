import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/contracts/order_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/MyAddressModel.old';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/PreOrderConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/CustomSwitchPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';


class OrderConfirmationPage2 extends StatefulWidget {

  static var routeName = "/OrderConfirmationPage2";

  Map<RestaurantFoodModel, int> addons, foods;

  int totalPrice;

  OrderConfirmationPresenter presenter;

  CustomerModel customer;

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

  _OrderConfirmationPage2State();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

    /*return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Montant Commande: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("${_orderBillConfiguration.command_pricing} FCFA", style: TextStyle(fontSize: 16))]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Montant Livraison: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("${_orderBillConfiguration.shipping_pricing} FCFA",  style: TextStyle(fontSize: 16))]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Remise: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)), Text("${_orderBillConfiguration.remise} FCFA",  style: TextStyle(fontSize: 16, color: Colors.green))]),
            SizedBox(height: 10),
            Container(height: 1, color: Colors.black,width: MediaQuery.of(context).size.width, padding: EdgeInsets.only(left: 10, right: 10)),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Net à Payer: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("${_orderBillConfiguration.total_pricing} FCFA",  style: TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor,fontSize: 18))]),
          ],
        ),
      ),
    );*/
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
              _buildBill(),
              SizedBox(height: 10),
              /* solde insuffisant  - CLIGNOTER CE CONTAINER */
              _orderBillConfiguration?.account_balance!=null && _orderBillConfiguration?.account_balance < _orderBillConfiguration?.total_pricing ?
              Container(margin: EdgeInsets.all(20), padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(children: <Widget>[
                    Text("${_orderBillConfiguration?.account_balance} FCFA ", style: TextStyle(fontWeight: FontWeight.bold,color: KColors.primaryColor, fontSize: 18)),
                    SizedBox(height: 20),
                    Text("${ _orderBillConfiguration?.account_balance!=null && _orderBillConfiguration?.account_balance < _orderBillConfiguration?.total_pricing ? "Solde insuffisant !" : "" }", style: TextStyle(color: Colors.black, fontSize: 18))
                  ])) :
              // we just tell him that he can prepay and stuffs.
              Container(),
              _buildPurchaseButtons()
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
          ), onPressed: () {}),
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
                    TextSpan(text: "${Utils.inflatePrice("${_orderBillConfiguration.account_balance}")} XOF",
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
            ],
          ), onPressed: () {}),
        ],
      ) : (!_orderBillConfiguration.prepayed ?
      Container(margin: EdgeInsets.only(left: 20, right:20), child: Text("You can't prepay because this restaurant doesn't allow prepay.",  textAlign: TextAlign.center, style: TextStyle(fontSize: 14,color: KColors.primaryColor, fontWeight: FontWeight.bold)))
          : Container(child: Text("You can't prepay because your balance is insufficient ",  textAlign: TextAlign.center, style: TextStyle(fontSize: 14,color: KColors.primaryColor, fontWeight: FontWeight.bold)))),
      SizedBox(height: 50),
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
                ],
              ), onPressed: () {}),
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

}
