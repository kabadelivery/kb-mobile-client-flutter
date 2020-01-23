import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailsPage extends StatefulWidget {

  static var routeName = "/OrderDetailsPage";

  OrderDetailsPage ({Key key, this.orderId}) : super(key: key);

  final int orderId;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState(orderId);
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  int orderId;

  _OrderDetailsPageState(this.orderId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CustomerUtils.getCustomer().then((customer) {
      userDataBloc.fetchOrderDetails(customer, orderId);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: KColors.primaryColor,
            title: Text("Command Details",
                style: TextStyle(fontSize: 20, color: Colors.white))),
        body: StreamBuilder<Object>(
            stream: userDataBloc.orderDetails,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _inflateDetails(snapshot.data);
              } else if (snapshot.hasError) {
                return ErrorPage(onClickAction: () {
                  CustomerUtils.getCustomer().then((customer) {
                    userDataBloc.fetchOrderDetails(customer, orderId);
                  });
                });
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Widget _inflateDetails(CommandModel command) {

    return SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Container(width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top:15, bottom:15, right:10, left:10),
                  color: Utils.getStateColor(command.state),child: Text(_orderTopLabel(command), textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white))),
              /* Progress line */
              Container(child: _getProgressTimeLine(command), margin: EdgeInsets.only(top:10, bottom:10),),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: RichText(
                    text: new TextSpan(
                      text: 'Latest Update: ',
                      style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: " ${_orderLastUpdate(command)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black.withAlpha(200))),
                      ],
                    ),
                  ),
                ),
              ),
              /* your contact */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Your contact", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${command?.shipping_address?.phone_number}", style: TextStyle(color: Colors.black, fontSize: 14))),
                ]),
              ),
              SizedBox(height: 10),
              /* command key */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Command key", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${command.state != COMMAND_STATE.WAITING && command.state != COMMAND_STATE.REJECTED  ?  command?.passphrase?.toUpperCase() : "---"}", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
                ]),
              ),
            ]..addAll(command.state > COMMAND_STATE.COOKING && command.state < COMMAND_STATE.REJECTED ?
            <Widget>[
              SizedBox(height: 10),
              /* KABA man name */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Kaba-man Name", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${command?.livreur?.name}", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal))),
                ]),
              ),
              SizedBox(height: 10),
              /* KABA man phone */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Kaba-man Phone", style: TextStyle(color: Colors.black, fontSize: 16))),
                  MaterialButton(padding: EdgeInsets.only(top:10,bottom:10, right:10,left:10),color: KColors.primaryColor, splashColor: Colors.white, child: Row(
                    children: <Widget>[
                      Icon(Icons.phone, color: Colors.white),
                      SizedBox(width: 5),
                      Text("${command?.livreur?.workcontact}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ), onPressed: () {}),
                ]),
              ),
            ]
                : <Widget>[Container()]
            )..addAll(<Widget>[
              SizedBox(height: 10),
              /* not so far from */
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Not so far from", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 10),
                        Text("${command?.shipping_address?.near}", style: TextStyle(color: Colors.black, fontSize: 14)),
                      ]),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Description", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.black, fontSize: 16)),
                        SizedBox(height: 10),
                        Text("${command?.shipping_address?.description}", style: TextStyle(color: Colors.black, fontSize: 14)),
                      ]),
                ),
              ),
              SizedBox(height: 10),
              /* food list*/
              Card(
                  child: Column(children:List.generate(command.food_list.length, (int index) {
                    return SingleOrderFoodWidget(command.food_list[index]);
                  }))),

              SizedBox(height: 10),
              /* bill */
              Card(
                  child: Container(padding: EdgeInsets.all(10),
                    child: Column(children:<Widget>[
//                      SizedBox(height: 10),
//                      "/web/assets/app_icons/promo_large.gif"
                      (int.parse(command?.remise) > 0 ? Container (
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
                            Text(int.parse(command?.price_command) > int.parse(command?.promotion_pricing) ? "(${command?.price_command})" : "", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                            SizedBox(width: 5),
                            Text(int.parse(command?.price_command) > int.parse(command?.promotion_pricing) ? "${command?.promotion_pricing} FCFA" : "${command?.price_command} FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      ]),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                        Text("Montant Livraison:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        /* check if there is promotion on Livraison */
                        Row(
                          children: <Widget>[
                            Text(int.parse(command?.shipping_pricing) > int.parse(command?.promotion_shipping_pricing) ? "(${command?.shipping_pricing})" : "", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                            Text(int.parse(command?.shipping_pricing) > int.parse(command?.promotion_shipping_pricing) ? "${command?.promotion_shipping_pricing} FCFA" : "${command?.shipping_pricing} FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      ]),
                      SizedBox(height: 10),
                      int.parse(command?.remise) > 0 ?
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                        Text("Remise:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
                        /* check if there is remise */
                        Text("-${command?.remise}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CommandStateColor.delivered)),
                      ]) : Container(),

                      SizedBox(height: 10),
                      Center(child: Container(width: MediaQuery.of(context).size.width - 10, color: Colors.black, height:1)),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                        Text("Net à Payer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("${command?.total_pricing} F", style: TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 18)),
                      ]),
                      SizedBox(height: 10),
                      (int.parse(command?.remise) > 0 ? Container (
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
                  )),
            ]
            ))
    );
  }

  String _orderTopLabel(CommandModel command) {
    switch(command.state) {
      case 0:
        return "ORDER IS WAITING";
      case 1:
        return "ORDER IS COOKING";
      case 2:
        return "ORDER'S HITTING THE ROAD";
      case 3:
        return "ORDER HAS BEEN DELIVERED";
        break;
      default:
        return "ORDER REJECTED";
    }
  }

  _orderLastUpdate(CommandModel command) {
    return Utils.readTimestamp(int.parse(command?.last_update));
  }

  _getProgressTimeLine(CommandModel command) {

    double PROGRESS_ICON_SIZE_PASSIVE = 25,  PROGRESS_ICON_SIZE_ACTIVE = 40;
    double LINE_HEIGHT = 40, LINE_WIDTH = 2, MARGIN=5;
    Color PASSIVE_COLOR = Colors.grey.withAlpha(100);

    return Column(children: <Widget>[

      /* waiting */
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              command.state == COMMAND_STATE.WAITING ?
              Container(decoration: BoxDecoration(color: CommandStateColor.waiting, borderRadius: BorderRadius.all(Radius.circular(5))), child: Text("En attente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),

              SizedBox(width: 10),
            ],
          )),
          Expanded(flex:0,
            child: Container(child: Icon(Icons.watch_later, size: command.state == COMMAND_STATE.WAITING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: command.state != COMMAND_STATE.WAITING ? PASSIVE_COLOR : Colors.grey)),
          ),
          Expanded(flex: 2,child: Container()),
        ],
      ),

      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(flex: 2,child: Container()),
          Expanded(flex: 0, child: Container(color: Colors.transparent, child: SizedBox(height: LINE_HEIGHT, width: LINE_WIDTH, child: Container( color: Colors.grey, margin: EdgeInsets.only(top:MARGIN, bottom:MARGIN))))),
          Expanded(flex: 2,child: Container()),
        ],
      ),

      /* cooking */
      Row(
        children: <Widget>[
          Expanded(flex: 2,child: Container()),
          Expanded(flex: 0,
            child: Container(child: Icon(FontAwesomeIcons.utensils, size: command.state == COMMAND_STATE.COOKING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: command.state != COMMAND_STATE.COOKING ? PASSIVE_COLOR : CommandStateColor.cooking)),
          ),
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10),
              command.state == COMMAND_STATE.COOKING ?
              Container(decoration: BoxDecoration(color: CommandStateColor.cooking, borderRadius: BorderRadius.all(Radius.circular(5))), child: Text("COOKING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),
            ],
          ))
        ],
      ),


      Container(height: LINE_HEIGHT, width: LINE_WIDTH, color: CommandStateColor.cooking,  margin: EdgeInsets.only(top:MARGIN, bottom:MARGIN)),


      /* shipping */
      Row(
        children: <Widget>[
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              command.state == COMMAND_STATE.SHIPPING ?
              Container(decoration: BoxDecoration(color: CommandStateColor.shipping, borderRadius: BorderRadius.all(Radius.circular(5))), child: Text("SHIPPING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),

              SizedBox(width: 10),
            ],
          )),
          Expanded(flex:0,
            child: Container(child: Icon(FontAwesomeIcons.biking, size: command.state == COMMAND_STATE.SHIPPING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: command.state != COMMAND_STATE.SHIPPING ? PASSIVE_COLOR : CommandStateColor.shipping)),
          ),
          Expanded(flex: 2,child: Container()),
        ],
      ),


      Container(height: LINE_HEIGHT, width: LINE_WIDTH, color: CommandStateColor.shipping,  margin: EdgeInsets.only(top:MARGIN, bottom:MARGIN)),

      /* delivered */
      Row(
        children: <Widget>[
          Expanded(flex: 2,child: Container()),
          Container(child: Icon(Icons.check_circle, size: command.state == COMMAND_STATE.DELIVERED ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
              color: command.state != COMMAND_STATE.DELIVERED ? PASSIVE_COLOR : CommandStateColor.delivered)
          ),
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10),
              command.state == COMMAND_STATE.DELIVERED ?
              Container(decoration: BoxDecoration(color: CommandStateColor.delivered, borderRadius: BorderRadius.all(Radius.circular(5))),   child: Text("DELIVERED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),
            ],
          ))
        ],
      ),

    ]);
  }

}
