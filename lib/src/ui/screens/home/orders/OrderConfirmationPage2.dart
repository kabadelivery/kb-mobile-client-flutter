import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  OrderConfirmationPage2({Key key, this.presenter, this.foods, this.addons, this.totalPrice}) : super(key: key);

  @override
  _OrderConfirmationPage2State createState() => _OrderConfirmationPage2State(totalPrice, foods, addons);
}

class _OrderConfirmationPage2State extends State<OrderConfirmationPage2> implements OrderConfirmationView {


  DeliveryAddressModel _selectedAddress;

  /* pricing configuration */
  OrderBillConfiguration _orderBillConfiguration;

  Map<RestaurantFoodModel, int> addons, foods;

  int totalPrice;

  bool isConnecting = false;

  _OrderConfirmationPage2State(this.totalPrice, this.foods, this.addons);

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
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
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
      widget.presenter.computeBilling(widget.customer, foods, _selectedAddress);
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
    return Card(
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
                  Text("${totalPrice}F", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
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
              Container(margin: EdgeInsets.all(20), padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(children: <Widget>[
                    Text("295 FCFA ", style: TextStyle(fontWeight: FontWeight.bold,color: KColors.primaryColor, fontSize: 18)),
                    SizedBox(height: 20),
                    Text("Solde insuffisant ! ", style: TextStyle(color: Colors.black, fontSize: 18))
                  ]))
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

}
