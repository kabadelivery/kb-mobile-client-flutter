import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/models/MyAddressModel.old';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/PreOrderConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/CustomSwitchPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class OrderConfirmationPage extends StatefulWidget {

  static var routeName = "/OrderConfirmationPage";

  Map<RestaurantFoodModel, int> addons, foods;

  int totalPrice;

  OrderConfirmationPage({Key key, this.foods, this.addons, this.totalPrice}) : super(key: key);

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState(totalPrice, foods, addons);
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {


  Widget _pay_prepayed_switch = CustomSwitchPage(button_1_name: "PRE-ORDER", button_2_name: "PAY NOW", active_text_color: KColors.primaryColor, unactive_text_color: Colors.white, active_button_color: Colors.white, unactive_button_color: KColors.primaryColor);

  /* pre-order configuration object */
  PreOrderConfiguration preOrderConfiguration = PreOrderConfiguration.fake();

  int preorder_timerange_selection = -1;

  MyAddressModel _selectedAddress;

  /* pricing configuration */
  OrderBillConfiguration orderBillConfiguration;

  Map<RestaurantFoodModel, int> addons, foods;

  int totalPrice;

  _OrderConfirmationPageState(this.totalPrice, this.foods, this.addons);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
          backgroundColor: KColors.primaryYellowColor ,
          title: Text("Confirm Order")
      ),
      body: _buildOrderConfirmationPage(null)
    );
  }

  _preorderLayout() {

    return <Widget>[
      SizedBox(height: 20),
      /* liste de plages horaires */
    ]..addAll(
        _preorderTimeRanges( preOrderConfiguration?.preorder_timeranges)
    );
  }


  void _pickDeliveryAddress() {

    /* jump and get it */

  }


  List<Widget> _preorderTimeRanges(List<String> preorder_timeranges) {

    List<Widget> m = <Widget>[];
    if (preorder_timeranges != null && preorder_timeranges.length > 0) {
      m.add(SizedBox(height: 10));
      m.add(Center(child: Text("A quelle periode preferez vous etre livrer?",style: TextStyle(color: Colors.black.withAlpha(150)))));
      m.add(SizedBox(height: 10));
      m.addAll(List.generate(preorder_timeranges.length, (int position){
        return _buildTimeRangeEntry(preorder_timeranges[position], position);
      }));
    } else {
      m.addAll(
          <Widget>[
            SizedBox(height: 10),
            Center(child: Text("Sorry, no time range to select for now. Preorder Later.")),
            SizedBox(height: 10),
          ]
      );
    }
    return m;
  }

  Widget _buildTimeRangeEntry(String preorder_timerang, int position) {

    return InkWell(onTap: (){
      setState(() {
        this.preorder_timerange_selection = position;
      });
    },
      splashColor: Colors.grey.withAlpha(20),
      child: Container(
        padding: EdgeInsets.only(left:20, right: 20, top:20, bottom: 20),
        color: Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${preorder_timerang}", style: TextStyle(
                fontSize: preorder_timerange_selection == position ? 20 : 18,
                color:  preorder_timerange_selection == position ? KColors.primaryColor : Colors.black,
              )),
              /* iconbutton that shows which one is selected */
              preorder_timerange_selection == position ? Icon(Icons.check_circle, color: KColors.primaryColor) : Container()
            ]),
      ),
    );


  }

  _buildAddress(MyAddressModel selectedAddress) {

    return Container(color: Colors.white, padding: EdgeInsets.all(10),
      child: Column(
          children: <Widget>[
            Container(child:
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

  _buildBill(OrderBillConfiguration orderBillConfiguration) {

    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Montant Commande: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("${orderBillConfiguration.command_pricing} FCFA", style: TextStyle(fontSize: 16))]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Montant Livraison: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text("${orderBillConfiguration.shipping_pricing} FCFA",  style: TextStyle(fontSize: 16))]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Remise: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)), Text("${orderBillConfiguration.remise} FCFA",  style: TextStyle(fontSize: 16, color: Colors.green))]),
            SizedBox(height: 10),
            Container(height: 1, color: Colors.black,width: MediaQuery.of(context).size.width, padding: EdgeInsets.only(left: 10, right: 10)),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text("Net à Payer: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("${orderBillConfiguration.total_pricing} FCFA",  style: TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor,fontSize: 18))]),
          ],
        ),
      ),
    );
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

  Widget _buildOrderConfirmationPage(PreOrderConfiguration data) {

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
            /*     Container(padding: EdgeInsets.only(top:10, bottom: 10, right: 15, left: 15), decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(const  Radius.circular(40.0)),
                border: new Border.all(color: KColors.primaryColor, width: 1),
              ), child: Row(mainAxisSize: MainAxisSize.min,children: <Widget>[Text("Prix Commmande", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) ,SizedBox(width: 10),
                Text("3.500FCFA", style: TextStyle(color: KColors.primaryYellowColor, fontWeight: FontWeight.bold, fontSize: 18))])),
              SizedBox(height: 10),*/
            Container(
              color: Colors.transparent,
              child: Container(
                  child: _pay_prepayed_switch
              ),
            ),
          ]..addAll( _preorderLayout())
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
              _buildAddress(MyAddressModel.fake()),
              SizedBox(height: 15),
              Center(child: Text("Utilisez un bon ? ",style: TextStyle(color: Colors.black.withAlpha(150)))),
              SizedBox(height: 15),
              /* set up the boxes for the bills */
              Row(children: <Widget>[
                SizedBox(width: 10),
                Expanded(flex: 1,child: Container(height: 120, decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: _buildRestaurantCoupon(),
                )),
                SizedBox(width: 10),
                Expanded(flex: 1,child: Container(height: 120, decoration: BoxDecoration(color: KColors.primaryYellowColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: _buildDeliveryCoupon(),
                )),  SizedBox(width: 10),
              ]),
              SizedBox(height: 10),
              _buildBill(orderBillConfiguration),
              SizedBox(height: 10),
              /* solde insuffisant  - CLIGNOTER CE CONTAINER */
              Container(margin: EdgeInsets.all(20), padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(children: <Widget>[
                    Text("295 FCFA ", style: TextStyle(fontWeight: FontWeight.bold,color: KColors.primaryColor, fontSize: 18)),
                    SizedBox(width: 10),
                    Text("Solde insuffisant ! ", style: TextStyle(color: Colors.black, fontSize: 18))
                  ]))
            ])
      ),
    );
  }


}
