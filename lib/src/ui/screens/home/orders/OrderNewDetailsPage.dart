import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/order_feedback_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/OrderItemModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/home/orders/CustomerFeedbackPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

import '../../../customwidgets/whatsappMessageButton.dart';

class OrderNewDetailsPage extends StatefulWidget {
  static var routeName = "/OrderNewDetailsPage";

  OrderDetailsPresenter presenter;

  OrderNewDetailsPage({Key key, this.orderId, this.presenter,this.is_out_of_app_order=false})
      : super(key: key);

  int orderId;
  bool is_out_of_app_order;
  CustomerModel customer;
  CommandModel command;

  @override
  _OrderNewDetailsPageState createState() => _OrderNewDetailsPageState();
}

class _OrderNewDetailsPageState extends State<OrderNewDetailsPage>
    implements OrderDetailsView {
  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  bool waitedForCustomerOnce = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.orderDetailsView = this;
    showLoading(true);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
      if (widget.orderId != null &&
          widget.orderId != 0 &&
          widget.command == null &&
          widget.customer != null) {
        widget.presenter.fetchOrderDetailsWithId(customer, widget.orderId,is_out_of_app_order:widget.is_out_of_app_order);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int args = ModalRoute.of(context).settings.arguments; 

    if (args != null && args != 0) {
      widget.orderId = args;
      if (widget.customer != null && widget.command == null) {
        // there must be a food id.
        widget.presenter
            .fetchOrderDetailsWithId(widget.customer, widget.orderId,is_out_of_app_order:widget.is_out_of_app_order);
      } else {
        // postpone it to the next second by adding showing the loading button.
        if (!waitedForCustomerOnce) {
          waitedForCustomerOnce = true;
          showLoading(true);
          Future.delayed(Duration(seconds: 1)).then((onValue) {
            if (widget.customer != null && widget.command == null) {
              widget.presenter
                  .fetchOrderDetailsWithId(widget.customer, widget.orderId,is_out_of_app_order:widget.is_out_of_app_order);
            }
          });
        }
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('order_details')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: MyLoadingProgressWidget())
            : (hasNetworkError
                ? _buildNetworkErrorPage()
                : hasSystemError
                    ? _buildSysErrorPage()
                    : _inflateDetails()));
  }

  var reasonsArray = [
    "menu_not_availabe",
    "restaurant_in_break",
    "restaurant_closed",
    "reason_beyond_control"
  ];

  // <string-array name="motives">
  // <item>Menu is not available</item>
  // <item>Restaurant in Pause</item>
  // <item>Restaurant in Closed</item>
  // <item>Your command has been rejected for reasons beyond our control.</item>
  // </string-array>

  Widget _inflateDetails() {
        int foodPriceTotal = 0; 
        print("Order type ${widget.command?.order_type}");
        
            if (widget.command?.food_list != null) {
      for (var item in widget.command.food_list) {
        item.price = item.price==""?"0":item.price;
        foodPriceTotal += int.parse(item.price);
      }
    }
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
                  color: Utils.getStateColor(widget?.command?.state),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget?.command?.is_preorder == 0
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white.withAlpha(100)),
                                  child: Text("Pre",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  padding: EdgeInsets.all(8)),
                          SizedBox(width: 5),
                          Text(Utils.capitalize(_orderTopLabel(widget.command)),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                          /* if rejected than we need a reason */
                        ],
                      ),
                      SizedBox(height: 5),
                      widget?.command?.state > 3
                          ? Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      width: 300,
                                      child: Text(
                                          "${AppLocalizations.of(context).translate('reason')}: ${_getReason()}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w200))),
                                ],
                              ),
                            )
                          : Container()
                    ],
                  )),
              /* Progress line */
              Container(
                child: _getProgressTimeLine(widget?.command),
                margin: EdgeInsets.only(top: 25, bottom: 20),
              ),
              (widget.command.state == 3 && widget.command.rating > 1
                  ? SizedBox(height: 10)
                  : Container()),
              (widget.command.state == 3)
                  ? (widget.command.rating > 1
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 30),
                          decoration: BoxDecoration(
                              color: KColors.primaryYellowColor.withAlpha(30),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: List<Widget>.generate(5,
                                                (int index) {
                                              return Icon(
                                                  index <
                                                          widget
                                                              ?.command?.rating
                                                      ? FontAwesomeIcons
                                                          .solidStar
                                                      : FontAwesomeIcons.star,
                                                  color: KColors
                                                      .primaryYellowColor,
                                                  size: 20);
                                            })
                                              ..addAll([
                                                SizedBox(width: 10),
                                                Text(
                                                    "${widget?.command?.rating}.0",
                                                    style: TextStyle(
                                                        fontSize: 32,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                      ),
                                      Text(
                                          " ${_orderLastUpdate(widget.command)}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                          child: RichText(
                                              text: TextSpan(
                                                  text: widget
                                                      ?.customer?.nickname,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: KColors.new_black,
                                                      fontSize: 12),
                                                  children: [
                                            TextSpan(
                                                text:
                                                    "  ${widget?.command?.comment == null ? "" : widget?.command?.comment} ",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12))
                                          ])

                                              /*  Text(
                                          "${widget?.command?.comment == null ? "" : widget?.command?.comment} ",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17))*/

                                              )),
                                    ],
                                  )
                                ]),
                          ))
                      : GestureDetector(
                          onTap: () => _reviewOrder(),
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            decoration: BoxDecoration(
                                color: KColors.primaryYellowColor.withAlpha(30),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Center(
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 20,
                                    ),
                                    Row(
                                      children: [
                                        Icon(FontAwesomeIcons.solidStar,
                                            size: 20,
                                            color: KColors.primaryYellowColor),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            "${AppLocalizations.of(context).translate("review_us")}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    KColors.primaryYellowColor))
                                      ],
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: KColors.primaryYellowColor)
                                  ]),
                            ),
                          ),
                        ))
                  : Container(),
              (widget.command.rating < 1 &&
                      Utils.within3days(widget.command?.last_update)
                  ? SizedBox(height: 10)
                  : Container()),
              /* your contact */

              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                decoration: BoxDecoration(
                    color: KColors.new_gray,
                    borderRadius: BorderRadius.circular(5)),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 0.8, color: Colors.grey.withAlpha(35)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Container(
                                color: KColors.new_gray,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                    "${AppLocalizations.of(context).translate('your_contact')}",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)))),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                color: KColors.new_gray,
                                child: Text(
                                    "${widget.command?.shipping_address?.phone_number}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontSize: 14)))),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: widget?.command?.state >
                                        COMMAND_STATE.COOKING &&
                                    widget?.command?.state <
                                        COMMAND_STATE.REJECTED
                                ? 0.8
                                : 0,
                            color: Colors.grey.withAlpha(35)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Container(
                                color: KColors.new_gray,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                    "${AppLocalizations.of(context).translate('command_key')}",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)))),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                color: KColors.new_gray,
                                child: Text(
                                    "${widget?.command?.state != COMMAND_STATE.WAITING && widget?.command?.state != COMMAND_STATE.REJECTED ? widget.command?.passphrase?.toUpperCase() : "---"}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontSize: 14)))),
                      ],
                    ),
                  ),
                ]),
              ),
            ]
              ..addAll(widget?.command?.state > COMMAND_STATE.COOKING &&
                      widget?.command?.state < COMMAND_STATE.REJECTED
                  ? <Widget>[
                      /* KABA man name */
                      Container(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: KColors.new_gray,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5))),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('kaba_man_name')}",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    child: Text(
                                        "${widget?.command?.livreur?.name}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: KColors.new_black,
                                            fontSize: 14))),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () => _callNumber(
                                      widget?.command?.livreur?.workcontact),
                                  child: Container(
                                      child: Icon(
                                        FontAwesomeIcons.phone,
                                        color: KColors.mBlue,
                                        size: 15,
                                      ),
                                      decoration: BoxDecoration(
                                          color: KColors.mBlue.withAlpha(30),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      padding: EdgeInsets.all(8)),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ]
                  : <Widget>[Container()])
              ..addAll(<Widget>[
                SizedBox(height: 10),
                /* not so far from */
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, right: 10, left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "${AppLocalizations.of(context).translate('not_far_from')}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: KColors.new_gray,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text(
                                Utils.capitalize(
                                    "${widget.command?.shipping_address?.near}"),
                                style: TextStyle(
                                    color: KColors.new_black, fontSize: 12)),
                          ),
                        ]),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 20, right: 10, left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "${AppLocalizations.of(context).translate('description')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 14)),
                          SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: KColors.new_gray,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Text(
                                Utils.capitalize(
                                    "${widget.command?.shipping_address?.description}"),
                                style: TextStyle(
                                    color: KColors.new_black, fontSize: 12)),
                          ),
                        ]),
                  ),
                ),
                SizedBox(height: 10),
                widget.command?.infos == null ||
                        widget.command?.infos?.trim()?.length == 0
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: CommandStateColor.delivered.withAlpha(30)),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Text(
                                    "${AppLocalizations.of(context).translate('informations')}: ${widget.command.infos}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: CommandStateColor.delivered))),
                          ],
                        )),
                SizedBox(height: 10),
                /* food list*/
                Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: KColors.new_gray,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Column(
                        children: List.generate(widget.command.food_list.length,
                            (int index) {
                      return _buildBasketItem(widget.command.food_list[index],
                          widget.command.food_list[index].quantity);
                    }))),
                SizedBox(height: 10),
                /* if we have a voucher, we will show it */
                _buildVoucher(),
                SizedBox(height: 10),
                /* bill */
                widget?.command?.kaba_point_used_amount != null &&
                        widget?.command?.kaba_point_used_amount > 0
                    ? showKabaPointUsed()
                    : Container(),
                _buildBill(),
                SizedBox(height: 10),
                widget.command.order_type==5 && widget.command?.state==3 && foodPriceTotal>0?
                WhatsappMessageButton("${AppLocalizations.of(context).translate("contact_us_for_funds")}",
"""
*Récupération de fonds*

Bonjour,

Je souhaite récupérer les fonds de ma commande 

*Détails de la commande*
- *ID*: ${widget.command.id}
- *Marchand*: ${widget.command.restaurant_entity.name}
- *Client*: ${widget.customer.nickname}
- *Numéro de téléphone*: ${widget.customer.phone_number}
- *Total*: ${foodPriceTotal}
- *Date*: ${widget.command.start_date}

""","91215301",)
                :Container(),
                SizedBox(height: 30),
              ]
              
              )));
  }

  Widget _buildBasketItem(OrderItemModel food, int quantity) {
    print("_buildBasketItem $food");
    return Container(
        margin: EdgeInsets.only(top: 4, bottom: 4),
        child: InkWell(
            child: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.only(left: 10),
                leading: Stack(
                  // overflow: Overflow.visible,
//                        _keyBox.keys.firstWhere(
//                        (k) => curr[k] == "${menuIndex}-${foodIndex}", orElse: () => null);
                  /* according to the position of the view, menu - food, we have a key that we store. */
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          image:widget.command.order_type==0? new DecorationImage(
                              fit: BoxFit.cover,
                              image: 
                              CachedNetworkImageProvider(
                                  Utils.inflateLink(food.pic)))
                                  :
                                  food.pic==null?null:new DecorationImage(
                                  fit: BoxFit.cover,
                                   image:  NetworkImage(food.pic))
                    )
                    ),
                  ],
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${Utils.capitalize(food?.name)}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: KColors.new_black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: KColors.primaryColor.withAlpha(40),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(children: <Widget>[
                            Text("${food?.price}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    decoration: food.promotion != 0 &&food.promotion!=null
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: KColors.new_black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(width: 5),
                            (food.promotion != 0&&food.promotion!=null
                                ? Text("${food?.promotion_price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal))
                                : Container()),
                            SizedBox(width: 1),
                            Text(
                                "${AppLocalizations.of(context).translate('currency')}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: KColors.new_black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal)),
                          ]),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(" X ${quantity}",
                            style: TextStyle(
                                color: KColors.new_black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
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

  String _orderTopLabel(CommandModel command) {
    switch (widget?.command?.state) {
      case 0:
        return "${AppLocalizations.of(context).translate('order_waiting')}"
            .toUpperCase();
      case 1:
        return "${AppLocalizations.of(context).translate('order_cooking')}"
            .toUpperCase();
      case 2:
        return "${AppLocalizations.of(context).translate('order_deliverying')}"
            .toUpperCase();
      case 3:
        return "${AppLocalizations.of(context).translate('order_delivered')}"
            .toUpperCase();
        break;
      default:
        return "${AppLocalizations.of(context).translate('order_rejected')}"
            .toUpperCase();
    }
  }

  _orderLastUpdate(CommandModel command) {
    return Utils.readTimestamp(context, int.parse(widget.command?.last_update));
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

  Color _getStateColor(int state) {
    switch (widget.command.state) {
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

  _getProgressTimeLine(CommandModel command) {
    return Column(
      children: [
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Icon(Icons.watch_later,
                    color: CommandStateColor.waiting.withAlpha(100), size: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: CommandStateColor.waiting.withAlpha(30),
                    shape: BoxShape.circle)),
            SizedBox(width: 5),
            Container(
                height: 2,
                color: CommandStateColor.waiting.withAlpha(100),
                width: MediaQuery.of(context).size.width / 8),
            SizedBox(width: 5),
            Container(
                child: Icon(FontAwesomeIcons.utensils,
                    color: KColors.primaryColor, size: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: KColors.primaryColor.withAlpha(30),
                    shape: BoxShape.circle)),
            SizedBox(width: 5),
            Container(
                height: 2,
                color: KColors.primaryColor,
                width: MediaQuery.of(context).size.width / 8),
            SizedBox(width: 5),
            Container(
                child: Icon(Icons.directions_bike,
                    color: CommandStateColor.shipping, size: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: CommandStateColor.shipping.withAlpha(30),
                    shape: BoxShape.circle)),
            SizedBox(width: 5),
            Container(
                height: 2,
                color: CommandStateColor.shipping,
                width: MediaQuery.of(context).size.width / 8),
            SizedBox(width: 5),
            Container(
                child: Icon(Icons.check_circle,
                    color: CommandStateColor.delivered, size: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: CommandStateColor.delivered.withAlpha(30),
                    shape: BoxShape.circle)),
          ],
        )),
        SizedBox(height: 10),
        Container(
            child: Text("${Utils.capitalize(_getStateLabel(command))}",
                style: TextStyle(
                    fontSize: 12, color: _getStateColor(command?.state))),
            decoration: BoxDecoration(
                color: _getStateColor(command?.state).withAlpha(30),
                borderRadius: BorderRadius.circular(5)),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
        SizedBox(height: 5),
        Container(
          child: Text("${_getLastModifiedDate(command)}",
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Future<void> inflateOrderDetails(CommandModel command) async {
    // showLoading(false);
    setState(() {
      widget.command = command;
    });
  }

  _reviewOrder() async {
    if (widget.command.rating < 1 &&
        widget.command.state == 3 /*within 3 days, you can still do it.*/) {
      // must review.
      /* jump to review pager. */
      Map results = await Navigator.of(context).push(PageRouteBuilder(
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

      if (results != null && results.containsKey('ok')) {
        bool feedBackOk = results['ok'];
        if (feedBackOk) {
          widget.presenter
              .fetchOrderDetailsWithId(widget.customer, widget?.command?.id,is_out_of_app_order:widget.is_out_of_app_order);
        }
      }
    } else {
      // can't review or we don't have to review.
      Toast.show("cant post review", context);
    }
  }

  @override
  void logoutTimeOutSuccess() {
    // TODO: implement logoutTimeOutSuccess
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasNetworkError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void systemError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasSystemError = true;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter
              .fetchOrderDetailsWithId(widget.customer, widget.orderId,is_out_of_app_order:widget.is_out_of_app_order);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter
              .fetchOrderDetailsWithId(widget.customer, widget.orderId,is_out_of_app_order:widget.is_out_of_app_order);
        });
  }

  _buildBill() {
    int priceNormalCommand,
        priceActualCommand,
        priceTotalToPay,
        priceNormalDelivery,
        additionnalFee,
        priceActualDelivery;

    priceNormalCommand = widget.command.food_pricing;

    bool showRemise = true, showDeliveryNormal = true, showFoodNormal = true;

    // depends
    if (widget?.command?.is_preorder == 1) {
      priceTotalToPay = widget.command.preorder_food_pricing;
      priceActualCommand = widget.command.preorder_food_pricing;
      priceActualDelivery = widget.command.preorder_shipping_pricing;
      priceNormalCommand = widget.command.food_pricing;
      priceNormalDelivery = widget.command.shipping_pricing;
      additionnalFee=widget.command.additionnal_fee;
    } else if (widget.command.is_promotion == 1) {
      priceTotalToPay = widget.command.promotion_total_pricing;
      priceActualCommand = widget.command.promotion_food_pricing;
      priceActualDelivery = widget.command.promotion_shipping_pricing;
      priceNormalCommand = widget.command.food_pricing;
      priceNormalDelivery = widget.command.shipping_pricing;
      additionnalFee=widget.command.additionnal_fee;
    } else if (widget.command.is_promotion == 0 &&
        widget?.command?.is_preorder == 0) {
      priceTotalToPay = widget.command.total_pricing;
      priceActualCommand = widget.command.food_pricing;
      priceActualDelivery = widget.command.shipping_pricing;
      additionnalFee=widget.command.additionnal_fee;
      showRemise = false;
      showDeliveryNormal = false;
      showFoodNormal = false;
    }

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: !widget.command.is_payed_at_arrival ? CommandStateColor.delivered.withAlpha(30) : KColors.new_gray, borderRadius: BorderRadius.circular(5)),
      child: Column(children: <Widget>[
//                      SizedBox(height: 10),
//                      "/web/assets/app_icons/promo_large.gif"
   /*     (int.parse(widget.command?.remise) > 0
            ? Container(
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink(
                            "/web/assets/app_icons/promo_large.gif")))))
            : Container()),*/
        Container(),
        /* content */
        SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${AppLocalizations.of(context).translate('order_amount')}",
                  style: TextStyle(fontSize: 14)),
              /* check if there is promotion on Commande */
              Row(
                children: <Widget>[
                  Row(
                    // only show if there is promotion on food
                    children: <Widget>[
                      Text("($priceNormalCommand)",
                          style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(width: 5),
                    ],
                  ),
                  Text("$priceActualCommand", style: TextStyle(fontSize: 15)),
                ],
              )
            ]),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
            Widget>[
          Text("${AppLocalizations.of(context).translate('delivery_amount')}",
              style: TextStyle(fontSize: 15)),
          /* check if there is promotion on Livraison */
          Row(
            children: <Widget>[
              widget?.command?.is_preorder == 1 ||
                      widget?.command?.is_promotion == 1
                  ? Row(
                      // only show if there is pre-order or promotion on the fees of delivery
                      children: <Widget>[
                        Text("($priceNormalDelivery)",
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                        SizedBox(width: 5),
                      ],
                    )
                  : Container(),
              Text("${priceActualDelivery}", style: TextStyle(fontSize: 15)),
            ],
          ),


        ]),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          Text("${AppLocalizations.of(context).translate('additional_fees')}",
              style: TextStyle(fontSize: 15)),
          Text("${additionnalFee}", style: TextStyle(fontSize: 15)),
        ]),
        SizedBox(height: 10),

        //additionnal fees
        SizedBox(height: 10),
        int.parse(widget.command?.remise) > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context).translate('discount')}:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey)),
                    /* check if there is remise */
                    Text("-${widget.command?.remise}%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: CommandStateColor.delivered)),
                  ])
            : Container(),

        SizedBox(height: 10),
        Center(
            child: Container(
                width: MediaQuery.of(context).size.width - 10,
                color: Colors.grey.withAlpha(100),
                height: 1)),
        SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${AppLocalizations.of(context).translate('net_price')}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: KColors.new_black.withAlpha(200))),
              Text(
                  "${widget?.command?.is_preorder == 0 ? priceTotalToPay : widget.command.preorder_total_pricing}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: KColors.primaryColor,
                      fontSize: 18)),
            ]),
    /*    SizedBox(height: 10),
      (int.parse(widget.command?.remise) > 0
            ? Container(
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Utils.inflateLink(
                            "/web/assets/app_icons/promo_large.gif")))))
            : Container()),*/
        SizedBox(
          height: 20,
        ),
    !widget.command.is_payed_at_arrival  ? Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: CommandStateColor.delivered,
                size: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "${AppLocalizations.of(context).translate("payed")}".toUpperCase(),
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: CommandStateColor.delivered),
              )
            ],
          ),
        ) : Container()
    ,
   
 
      ]
      ),
    );
  }

  Future<void> _callNumber(String workcontact) async {
    var url = "tel:+228${workcontact}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      Toast.show("Call error", context);
    }
  }

  _buildVoucher() {
    // build voucher if we have it
    if (widget?.command != null &&
        widget?.command?.voucher_entity != null &&
        widget?.command?.voucher_entity?.id != null) {
      return MyVoucherMiniWidget(voucher: widget?.command?.voucher_entity);
    }
    return Container();
  }

  _getReason() {
    if (widget.command.reason >= reasonsArray.length)
      return "${AppLocalizations.of(context).translate('reason_beyond_control')}";
    return "${AppLocalizations.of(context).translate('${reasonsArray[widget.command.reason - 1 < 0 ? 0 : widget.command.reason - 1]}')}";
  }

  showKabaPointUsed() {
    // kaba_point_used_amount
    return Container(
        child: RichText(
            text: TextSpan(
                text:
                    "${AppLocalizations.of(context).translate("kaba_point_used_amount")}",
                style: TextStyle(color: Colors.white, fontSize: 12),
                children: <TextSpan>[
              TextSpan(
                  text: "${widget.command.kaba_point_used_amount}  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))
            ])),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: KColors.primaryColor));
  }
}
