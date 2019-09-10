import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/OrderItemModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class MyOrderWidget extends StatefulWidget {

  CommandModel command;

  MyOrderWidget({this.command});

  @override
  _MyOrderWidgetState createState() {
    // TODO: implement createState
    return _MyOrderWidgetState(command);
  }
}

class _MyOrderWidgetState extends State<MyOrderWidget> {

  CommandModel command;

  _MyOrderWidgetState(this.command);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    command.is_payed_at_arrival = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      InkWell(
        onTap: ()=> _jumpToCommandDetails(command),
        child: Container(
          padding: EdgeInsets.only(top:100, bottom:100),
          child: Center(
            child: (Card(
                elevation: 8.0,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                    child:
                    Column(children: <Widget>[
                      Container(padding: EdgeInsets.all(5), color: _getStateColor(command.state), child:
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                        Row(children: <Widget>[
                          Container(
                              height: 45, width: 45,
                              decoration: BoxDecoration(
                                  border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(Utils.inflateLink(command.restaurant_entity.pic))
                                  )
                              )
                          ),
                          SizedBox(width: 10),
                          Text("${command.restaurant_entity.name}", style: TextStyle(color: Colors.white, fontSize: 14))
                        ]),
                        Container(padding: EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white.withAlpha(100),
//                            border: new Border.all(color: Colors.white.withAlpha(100)),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                            child: Text(_getStateLabel(command), overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))
                      ]))
                    ]..addAll(_orderFoodList(command?.food_list))
                      ..addAll(<Widget>[
                        /* shipping part */
                        Row(   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.local_shipping, size: 40,)),
                            Text("SHIPPING PRICE", style: TextStyle(fontSize: 18, color: Colors.grey),),
                            Container(color: Colors.grey,padding: EdgeInsets.only(top:5, bottom:5, right:5, left:5),child: Text("${command.shipping_pricing} F", style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white, fontSize: 16)))
                          ],
                        ),
                        /* quartier */
                        Center(child: Container(decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.grey
                        ),padding: EdgeInsets.only(top:5, bottom:5, right:5, left:5),child: Text("${command.shipping_address.quartier}", style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white, fontSize: 16)))),
                        Container(padding: EdgeInsets.only(top:10),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                            Container(padding: EdgeInsets.only(left:10, right:10),child: Text(_getLastModifiedDate(command), style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic))),
                            Row(children: <Widget>[
                              Text('TOTAL: ',style: new TextStyle(color: Colors.black, fontSize: 18)),
                              Container(child: Text("${command.total_pricing} F", style: TextStyle(fontSize: 16,color: Colors.white)), color: KColors.primaryColor, padding: EdgeInsets.all(10))
                            ])
                          ]),
                        ),
                        /* pay at arrival condition? */
                        command.is_payed_at_arrival ? Container(padding: EdgeInsets.only(top:8, bottom:8), color: KColors.mBlue,child: Center(child: Text("PAY AT ARRIVAL", style: TextStyle(color: Colors.white,fontSize: 20),))) : Container(),
                      ])
                    )
                ))
            ),
          ),
        ),
      );
  }

  List<Widget> _orderFoodList(List<OrderItemModel> food_list) {

    return List.generate(food_list?.length, (int index){
      return SingleOrderFoodWidget(food_list[index]);
//      return Container();
    })?.toList();
  }

  _getStateColor(int state) {
    switch(command.state) {
      case 0:
        return CommandStateColor.waiting;
      case 1:
        return CommandStateColor.cooking;
      case 2:
        return CommandStateColor.shipping;
      case 3:
        return CommandStateColor.delivered;
      default:
        return CommandStateColor.cancelled;
    }
  }

  String _getStateLabel(CommandModel command) {
    // delivered ?
    switch(command.state) {
      case 0:
        return "WAITING";
      case 1:
        return "COOKING";
      case 2:
        return "SHIPPING";
      case 3:
        return "DELIVERED";
        break;
      default:
        return "REJECTED";
    }
  }

  String _getLastModifiedDate(CommandModel command) {
   return Utils.timestampToDate(command.last_update);
  }

  _jumpToCommandDetails(CommandModel command) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: command.id),
      ),
    );
  }
}



class SingleOrderFoodWidget extends StatelessWidget {

  OrderItemModel food;

  SingleOrderFoodWidget(this.food);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(padding: EdgeInsets.only(top:10,bottom:10,left:5, right:5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /* name and picture */
            Row(children: <Widget>[
              Container(
                  height: 65, width: 65,
                  decoration: BoxDecoration(
                      border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
                      )
                  )
              ),
              SizedBox(width: 10,),
              Column(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
                Text("${food.name}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: KColors.primaryColor, fontWeight: FontWeight.bold)),
                Row(children: <Widget>[
                  Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                  (food?.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                      : Container()),
                  Text("FCFA", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                ]),
              ])
            ]),
            /* quantity and cross */
            RichText(
              text: new TextSpan(
                text: 'X ',
                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: " ${food.quantity}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                ],
              ),
            ),
          ]
      ),
    );
  }
}



/*
*
*
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
              child:
              Column(children: <Widget>[
                ListTile(
                    contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                    leading: Container(
                      height:50, width: 50,
                      child:CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png"),
                    ),
                    trailing: IconButton(icon: Icon(Icons.menu, color: KColors.primaryColor,), onPressed: (){}),
                    title:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("CHEZ ARMANDINE", textAlign: TextAlign.left, style: TextStyle(color:KColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w500)),
                        SizedBox(height:10),
                        Text("Qtier Agoe Plateaux; Agence-annexe - We are not very far from carefour assigomé! Turn right and we are there", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    )
                ),
                Container(
                    padding: EdgeInsets.all(5),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: Colors.blueAccent.shade700),
                            child:Text(
                                "Closed",
                                style: TextStyle(color: Colors.white, fontSize: 12)
                            )),
                        Text("2.15km", style: TextStyle(color: Colors.grey.shade700, fontSize: 12))
                      ],
                    ))
              ])
          ))
      );
  }

*
* */