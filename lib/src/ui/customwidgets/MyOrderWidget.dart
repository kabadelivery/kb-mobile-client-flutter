import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/OrderItemModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyOrderWidget extends StatefulWidget {

  CommandModel command;

//  VoucherModel voucher = VoucherModel(type: 1);

  MyOrderWidget({this.command});

  @override
  _MyOrderWidgetState createState() {
    return _MyOrderWidgetState(command);
  }
}

class _MyOrderWidgetState extends State<MyOrderWidget> {

  CommandModel command;

  _MyOrderWidgetState(this.command);

  /* restaurant voucher gradient */
  var restaurantVoucherBg = [Color(0xFFEAEB12), Color(0xFFF1AA00)];
  /* delivery voucher gradient */
  var deliveryVoucherBg = [Color(0xFFCC1641), Color(0xFFFF7E9C)];
  /* all voucher gradient */
  var bothVoucherBg = [ Color(0xFFEEEEEE), Color(0xFFFFFFFF)];

  var textColorWhite = Color(0xFFFFFFFF);
  var textColorBlack = Color(0xFF000000);
  var textColorYellow = KColors.colorMainYellow;
  var textColorRed = KColors.colorCustom;

  var restaurantNameColor, priceColor, voucherCodeColor, expiresDateColor, typeIconColor;

  @override
  void initState() {
    super.initState();

    switch(widget?.command?.voucher_entity?.type){
      case 1: // restaurant (yellow background)
        restaurantNameColor = textColorWhite;
        priceColor = textColorRed;
        voucherCodeColor = textColorRed;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorBlack;
        break;
      case 2: // delivery (red background)
        restaurantNameColor = textColorBlack;
        priceColor = textColorYellow;
        voucherCodeColor = textColorWhite;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorWhite;
        break;
      case 3: // both (white bg)
        restaurantNameColor = textColorBlack;
        priceColor = textColorYellow;
        voucherCodeColor = textColorRed;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorBlack;
        break;
    }
  }

  List<String> dayz = [];

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
    return
      InkWell(
        onTap: ()=> _jumpToCommandDetails(command),
        child: Container(
          padding: EdgeInsets.only(bottom:10),
          child: Center(
            child: Column(
              children: <Widget>[
                // just in case this is a preorder
                SizedBox(height: 10),
                widget?.command?.is_preorder == 1 ? Container(color: KColors.primaryColor, margin: EdgeInsets.only(left:10, right:10), padding: EdgeInsets.only(top: 8, bottom: 8),child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text("${AppLocalizations.of(context).translate('delivery_day')}", style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 5), Text("${Utils.timeStampToDayDate(widget.command.preorder_hour.start, dayz: dayz)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))])) : Container(),
                widget?.command?.is_preorder == 1 ? Container(color: Colors.black, margin: EdgeInsets.only(left:10, right:10), padding: EdgeInsets.only(top: 8, bottom: 8),child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Text("${AppLocalizations.of(context).translate('delivery_time_frame')}", style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 5), Text("${Utils.timeStampToHourMinute(widget.command.preorder_hour.start)} à ${Utils.timeStampToHourMinute(widget.command.preorder_hour.end)}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))])) : Container(),
                (Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0),
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
                              Text("${command.restaurant_entity.name}", style: TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)
                            ]),
                            Container(padding: EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white.withAlpha(100),
//                            border: new Border.all(color: Colors.white.withAlpha(100)),
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                                child: Text(_getStateLabel(command), overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
                          ]))
                        ]..addAll(_orderFoodList(command?.food_list))
                          ..addAll(<Widget>[
                            /* shipping part */
                            Row(   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(icon: Icon(Icons.local_shipping, size: 40,)),
                                Text("${AppLocalizations.of(context).translate('shipping_price')}".toUpperCase(), style: TextStyle(fontSize: 17, color: Colors.grey),),
                                Container(color: Colors.grey,padding: EdgeInsets.only(top:5, bottom:5, right:5, left:5),child: Text("${command?.is_preorder == 1 ? command.preorder_shipping_pricing :(command.is_promotion == 1 ? command.promotion_shipping_pricing : command.shipping_pricing)} F", style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white, fontSize: 16)))
                              ],
                            ),
                            /* quartier */
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                widget?.command?.voucher_entity != null ?  ClipPath(
                                    clipper: MiniVoucherClipper(),
                                    child: Container(width:70,height:40,
                                        margin: EdgeInsets.only(left:10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                                            colors: widget?.command?.voucher_entity?.type == 1 ? restaurantVoucherBg : (widget?.command?.voucher_entity?.type == 2 ? deliveryVoucherBg : bothVoucherBg),
                                            tileMode: TileMode.repeated, // repeats the gradient over the canvas
                                          ),
                                        ),
                                        child: Center(child:Text("- ${widget?.command?.voucher_entity?.value}${widget?.command?.voucher_entity?.category == 1 ? "%" : "F"}", style: TextStyle(color:priceColor, fontWeight: FontWeight.bold))))) :  Container(width: 10, height: 8),
                                Container(decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: Colors.grey
                                ),
                                    padding: EdgeInsets.only(top:5, bottom:5, right:5, left:5),
                                    child: Text("${command.shipping_address.quartier}",
                                        style: TextStyle(fontWeight:FontWeight.bold,
                                            color: Colors.white, fontSize: 16))),
                                Container(width: 10, height: 8)
                              ],
                            ),
                            Container(padding: EdgeInsets.only(top:10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Container(padding: EdgeInsets.only(left:10, right:10),child: Text(_getLastModifiedDate(command), style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic))),
                                Row(children: <Widget>[
                                  Text('${AppLocalizations.of(context).translate('total')}: '.toUpperCase(),style: new TextStyle(color: Colors.black, fontSize: 18)),
                                  Container(child: Text("${command?.is_preorder == 1 ? command.preorder_total_pricing :(command.is_promotion == 1 ? command.promotion_total_pricing : command.total_pricing)} F", style: TextStyle(fontSize: 16,color: Colors.white)), color: KColors.primaryColor, padding: EdgeInsets.all(10))
                                ])
                              ]),
                            ),
                            /* pay at arrival condition? */
                            command.is_payed_at_arrival ? Container(padding: EdgeInsets.only(top:8, bottom:8), color: KColors.mBlue,child: Center(child: Text("${AppLocalizations.of(context).translate('pay_at_arrival')}", style: TextStyle(color: Colors.white,fontSize: 20),))) : Container(),
                          ])
                        )
                    ))
                ),
              ],
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
        return "${AppLocalizations.of(context).translate('waiting')}".toUpperCase();
      case 1:
        return "${AppLocalizations.of(context).translate('cooking')}".toUpperCase();
      case 2:
        return "${AppLocalizations.of(context).translate('shipping')}".toUpperCase();
      case 3:
        return "${AppLocalizations.of(context).translate('delivered')}".toUpperCase();
        break;
      default:
        return "${AppLocalizations.of(context).translate('rejected')}".toUpperCase();
    }
  }

  String _getLastModifiedDate(CommandModel command) {
    return Utils.readTimestamp(int.parse(command?.last_update));
  }

  _jumpToCommandDetails(CommandModel command) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: command?.id, presenter: OrderDetailsPresenter()),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            OrderDetailsPage(orderId: command?.id, presenter: OrderDetailsPresenter()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }
}

class MiniVoucherClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 16;

    path.moveTo(0, radius);
    path.arcToPoint(Offset(radius, 0), clockwise: false, radius: Radius.circular(radius));
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height-radius), clockwise: false, radius: Radius.circular(radius));


//    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip (MiniVoucherClipper oldClipper) => true;

}


class SingleOrderFoodWidget extends StatelessWidget {

  OrderItemModel food;

  SingleOrderFoodWidget(this.food);

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.only(top:10,bottom:10,left:5, right:5), width: MediaQuery.of(context).size.width,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /* name and picture */
            Flexible(flex: 7,
              child: Row(children: <Widget>[
                /* PICTURE */
                Container(
                  height: 65, width: 65,
                  decoration: BoxDecoration(
                      border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
                      )
                  ),
                ),
                SizedBox(width: 10),

                /* NAME AND PRICE ZONE */
                Flexible(flex: 2,
                  child: Container(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[

                      /* food name */
                      Text("${food.name?.toUpperCase()}", overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 16, color: KColors.primaryColor, fontWeight: FontWeight.bold)),

                      /* food price*/
                      Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        /* price has a line on top in case */
                        Text("${food?.price}", overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color: food.promotion!=0 ? Colors.black : KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: food.promotion!=0 ? TextDecoration.lineThrough : TextDecoration.none)),
                        SizedBox(width: 5),
                        (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.none))
                            : Container()),
                        Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                      ]),
                    ]),
                  ),
                ),
              ]),
            ),

            /* QUANTITY */
            RichText(
              text: new TextSpan(
                text: 'X ',
                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: " ${food.quantity} ", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                ],
              ),
            ),
          ]
      ),
    );
  }
}
