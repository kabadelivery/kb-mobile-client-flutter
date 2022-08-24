import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/order_feedback_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/OrderItemModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/home/orders/CustomerFeedbackPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart' as to;
import 'package:optimized_cached_image/optimized_cached_image.dart';

class MyNewOrderWidget extends StatefulWidget {
  CommandModel command;

//  VoucherModel voucher = VoucherModel(type: 1);

  MyNewOrderWidget({this.command});

  @override
  _MyNewOrderWidgetState createState() {
    return _MyNewOrderWidgetState(command);
  }
}

class _MyNewOrderWidgetState extends State<MyNewOrderWidget> {
  CommandModel command;

  _MyNewOrderWidgetState(this.command);

  /* restaurant voucher gradient */
  var restaurantVoucherBg = [Color(0xFFEAEB12), Color(0xFFF1AA00)];

  /* delivery voucher gradient */
  var deliveryVoucherBg = [Color(0xFFCC1641), Color(0xFFFF7E9C)];

  /* all voucher gradient */
  var bothVoucherBg = [Color(0xFFEEEEEE), Color(0xFFFFFFFF)];

  var textColorWhite = Color(0xFFFFFFFF);
  var textColorBlack = Color(0xFF000000);
  var textColorYellow = KColors.colorMainYellow;
  var textColorRed = KColors.colorCustom;

  var restaurantNameColor,
      priceColor,
      voucherCodeColor,
      expiresDateColor,
      typeIconColor;

  @override
  void initState() {
    super.initState();

    switch (widget?.command?.voucher_entity?.type) {
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
    return Opacity(
      opacity: command?.state > 3 ? .7 : 1,
      child: InkWell(
        onTap: () => _jumpToCommandDetails(command),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: KColors.new_gray,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(children: <Widget>[
                      Container(
                          height: 45,
                          width: 45,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: new Border.all(
                                  color: KColors.primaryYellowColor, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: OptimizedCacheImageProvider(
                                      Utils.inflateLink(
                                          command.restaurant_entity.pic))))),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 1 * MediaQuery.of(context).size.width / 2,
                            child: Text("${command?.restaurant_entity?.name}",
                                style: TextStyle(
                                    color: KColors.new_black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(height: 5),
                          RichText(
                              text: TextSpan(
                                  text:
                                      "${command?.is_payed_at_arrival ? AppLocalizations.of(context).translate('has_to_pay') : AppLocalizations.of(context).translate('already_paid')}  ",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                  children: [
                                TextSpan(
                                    text:
                                        "${command?.is_preorder == 1 ? command.preorder_total_pricing : (command.is_promotion == 1 ? command.promotion_total_pricing : command.total_pricing)} ${AppLocalizations.of(context).translate('currency')}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: KColors.primaryColor))
                              ]))
                        ],
                      )
                    ]),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5)),
                            color: _getStateColor(command?.state)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            command?.state > 1 && command?.state <= 3
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.directions_bike,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 5),
                                      Text("${widget?.command?.livreur?.name}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white)),
                                    ],
                                  )
                                : Container(height: 5),
                            /*shipping mode only*/
                            widget?.command?.state == 2 ||
                                   ( widget?.command?.state == 3 && (widget?.command?.rating == null || widget?.command?.rating < 1))
                                ? InkWell(
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(50),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                                widget?.command?.state == 2
                                                    ? Icons.call
                                                    : FontAwesomeIcons
                                                        .solidStar,
                                                color: Colors.white,
                                                size: 16),
                                            SizedBox(width: 5),
                                            Text(
                                                "${AppLocalizations.of(context).translate(widget?.command?.state == 2 ? 'call_me_shipper' : 'review')}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ],
                                        )),
                                    onTap: widget?.command?.state == 2
                                        ? () => _callShipper()
                                        : () => _reviewOrder())
                                : Container()
                          ],
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
                right: 20,
                top: 15,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          child: Text(
                              "${Utils.capitalize(_getStateLabel(command))}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _getStateColor(command?.state))),
                          decoration: BoxDecoration(
                              color:
                                  _getStateColor(command?.state).withAlpha(30),
                              borderRadius: BorderRadius.circular(5)),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 6)),
                      SizedBox(height: 5),
                      Container(
                        child: Text("${_getLastModifiedDate(command)}",
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                      )
                    ]))
          ],
        ),
      ),
    );
  }

  List<Widget> _orderFoodList(List<OrderItemModel> food_list) {
    return List.generate(food_list?.length, (int index) {
      return SingleOrderFoodWidget(food_list[index]);
//      return Container();
    })?.toList();
  }

  Color _getStateColor(int state) {
    switch (command.state) {
      case 0:
        return CommandStateColor.waiting;
      case 1:
        return CommandStateColor.cooking;
      case 2:
        return CommandStateColor.shipping;
      case 3:
        return CommandStateColor.delivered;
      default:
        return KColors.primaryColor;
    }
  }

  String _getStateLabel(CommandModel command) {
    // delivered ?
    switch (command.state) {
      case 0:
        return "${AppLocalizations.of(context).translate('waiting')}"
            .toUpperCase();
      case 1:
        return "${AppLocalizations.of(context).translate('cooking')}"
            .toUpperCase();
      case 2:
        return "${AppLocalizations.of(context).translate('shipping')}"
            .toUpperCase();
      case 3:
        return "${AppLocalizations.of(context).translate('delivered')}"
            .toUpperCase();
        break;
      default:
        return "${AppLocalizations.of(context).translate('rejected')}"
            .toUpperCase();
    }
  }

  String _getLastModifiedDate(CommandModel command) {
    return Utils.readTimestamp(context, int.parse(command?.last_update));
  }

  _jumpToCommandDetails(CommandModel command) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: command?.id, presenter: OrderDetailsPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderNewDetailsPage(
                orderId: command?.id, presenter: OrderDetailsPresenter()),
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
  }

  _callShipper() async {
    /* call shipper */
    var url = "tel:+228${widget?.command?.livreur?.workcontact}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      to.Toast.show("Call error", context);
    }
  }

  _reviewOrder() async {
    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderFeedbackPage(
                orderId: widget?.command?.id,
                presenter: OrderFeedbackPresenter()),
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
  }

}

class MiniVoucherClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 16;

    path.moveTo(0, radius);
    path.arcToPoint(Offset(radius, 0),
        clockwise: false, radius: Radius.circular(radius));
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius),
        clockwise: false, radius: Radius.circular(radius));

//    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(MiniVoucherClipper oldClipper) => true;
}

class SingleOrderFoodWidget extends StatelessWidget {
  OrderItemModel food;

  SingleOrderFoodWidget(this.food);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: MediaQuery.of(context).size.width,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /* name and picture */
            Flexible(
              flex: 7,
              child: Row(children: <Widget>[
                /* PICTURE */
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                      border: new Border.all(
                          color: KColors.primaryYellowColor, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: OptimizedCacheImageProvider(
                              Utils.inflateLink(food.pic)))),
                ),
                SizedBox(width: 10),

                /* NAME AND PRICE ZONE */
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          /* food name */
                          Text("${food.name?.toUpperCase()}",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: KColors.primaryColor,
                                  fontWeight: FontWeight.bold)),

                          /* food price*/
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                /* price has a line on top in case */
                                Text("${food?.price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: food.promotion != 0
                                            ? KColors.new_black
                                            : KColors.primaryYellowColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        decoration: food.promotion != 0
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none)),
                                SizedBox(width: 5),
                                (food.promotion != 0
                                    ? Text("${food?.promotion_price}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: KColors.primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none))
                                    : Container()),
                                Text(
                                    "${AppLocalizations.of(context).translate('currency')}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryYellowColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal)),
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
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: KColors.new_black),
                children: <TextSpan>[
                  TextSpan(
                      text: " ${food.quantity} ",
                      style:
                          TextStyle(fontSize: 24, color: KColors.primaryColor)),
                ],
              ),
            ),
          ]),
    );
  }
}
