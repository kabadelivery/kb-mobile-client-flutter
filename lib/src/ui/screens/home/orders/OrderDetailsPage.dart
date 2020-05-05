import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/contracts/order_details_contract.dart';
import 'package:kaba_flutter/src/contracts/order_feedback_contract.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/CustomerFeedbackPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {

  static var routeName = "/OrderDetailsPage";

  OrderDetailsPresenter presenter;


  OrderDetailsPage ({Key key, this.orderId, this.presenter}) : super(key: key);

  int orderId;
  CustomerModel customer;
  CommandModel command;


  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> implements OrderDetailsView {


  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.orderDetailsView = this;
    showLoading(true);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
      if (widget.orderId != null && widget.orderId != 0 && widget.command == null && widget.customer != null) {
        widget.presenter.fetchOrderDetailsWithId(customer, widget.orderId);
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
        widget.presenter.fetchOrderDetailsWithId(
            widget.customer, widget.orderId);
      } else {
        // postpone it to the next second by adding showing the loading button.
        showLoading(true);
        Future.delayed(Duration(seconds: 1)).then((onValue) {
          if (widget.customer != null && widget.command == null) {
            widget.presenter.fetchOrderDetailsWithId(
                widget.customer, widget.orderId);
          }
        });
      }
    }

    return Scaffold(
        appBar: AppBar(
            backgroundColor: KColors.primaryColor,
            title: Text("Command Details",
                style: TextStyle(fontSize: 20, color: Colors.white))),
        body: /*StreamBuilder<Object>(
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
            })*/
        isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
        _inflateDetails())
    );
  }

  Widget _inflateDetails() {

    return SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Container(width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top:15, bottom:15, right:10, left:10),
                  color: Utils.getStateColor(widget?.command?.state),child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      widget?.command?.is_preorder == 0 ? Container() :  Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white.withAlpha(100)),child: Text("Pre", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), padding: EdgeInsets.all(8)),
                      SizedBox(width: 5),
                      Text(_orderTopLabel(widget.command), textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white)),
                    ],
                  )),
              /* Progress line */
              Container(child: _getProgressTimeLine(widget?.command), margin: EdgeInsets.only(top:10, bottom:10),),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: RichText(
                    text: new TextSpan(
                      text: 'Latest Update: ',
                      style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: " ${_orderLastUpdate(widget.command)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black.withAlpha(200))),
                      ],
                    ),
                  ),
                ),
              ),
              (widget.command.state == 3 && widget.command.rating > 1 ? SizedBox(height: 10) : Container()),
              (widget.command.state == 3 && widget.command.rating > 1 ?
              Container(padding: EdgeInsets.all(10), margin: EdgeInsets.only(left:10, right:10, top:20, bottom:10),decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(child: Text("RATING", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))),
                          SizedBox(height: 5),
                          Row(children: <Widget>[]
                            ..addAll(
                                List<Widget>.generate(widget?.command?.rating, (int index) {
                                  return Icon(Icons.star, color: KColors.primaryYellowColor, size: 20);
                                })
                            )),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Flexible(child: Text(widget?.command?.comment, textAlign: TextAlign.left, style: TextStyle(color:Colors.white, fontSize: 17))),
                            ],
                          )
                        ]
                    ),
                  )) :  Container()
              ),
              (widget.command.rating < 1 && Utils.within3days(widget.command?.last_update) ? SizedBox(height: 10) : Container()),
              /* your contact */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Your contact", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${widget.command?.shipping_address?.phone_number}", style: TextStyle(color: Colors.black, fontSize: 14))),
                ]),
              ),
              SizedBox(height: 10),
              /* command key */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Command key", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${widget?.command?.state != COMMAND_STATE.WAITING && widget?.command?.state != COMMAND_STATE.REJECTED  ?  widget.command?.passphrase?.toUpperCase() : "---"}", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
                ]),
              ),
            ]..addAll(widget?.command?.state > COMMAND_STATE.COOKING && widget?.command?.state < COMMAND_STATE.REJECTED ?
            <Widget>[
              SizedBox(height: 10),
              /* KABA man name */
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                  Flexible (child: Text("Kaba-man Name", style: TextStyle(color: Colors.black, fontSize: 16))),
                  Flexible (child: Text("${widget?.command?.livreur?.name}", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal))),
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
                      Text("${widget.command?.livreur?.workcontact}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ), onPressed: () {_callNumber(widget?.command?.livreur?.workcontact);}),
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
                        Text("${widget.command?.shipping_address?.near}", style: TextStyle(color: Colors.black, fontSize: 14)),
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
                        Text("${widget.command?.shipping_address?.description}", style: TextStyle(color: Colors.black, fontSize: 14)),
                      ]),
                ),
              ),
              SizedBox(height: 10),
              widget.command?.infos == null || widget.command?.infos?.trim()?.length == 0 ? Container() : Container(margin: EdgeInsets.only(top:10, bottom:10),color: CommandStateColor.delivered, padding: EdgeInsets.all(10), child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text("Informations: ${widget.command.infos}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.white))),
                ],
              )),
              SizedBox(height: 10),
              /* food list*/
              Card(
                  child: Column(children:List.generate(widget.command.food_list.length, (int index) {
                    return SingleOrderFoodWidget(widget.command.food_list[index]);
                  }))),
              SizedBox(height: 10),
              /* bill */
              _buildBill(),
            ]
            ))
    );
  }

  String _orderTopLabel(CommandModel command) {
    switch(widget?.command?.state) {
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
    return Utils.readTimestamp(int.parse(widget.command?.last_update));
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

              widget?.command?.state == COMMAND_STATE.WAITING ?
              Container(decoration: BoxDecoration(color: CommandStateColor.waiting, borderRadius: BorderRadius.all(Radius.circular(5))), child: Text("En attente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),

              SizedBox(width: 10),
            ],
          )),
          Expanded(flex:0,
            child: Container(child: Icon(Icons.watch_later, size: widget?.command?.state == COMMAND_STATE.WAITING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: widget?.command?.state != COMMAND_STATE.WAITING ? PASSIVE_COLOR : Colors.grey)),
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
            child: Container(child: Icon(FontAwesomeIcons.utensils, size: widget?.command?.state == COMMAND_STATE.COOKING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: widget?.command?.state != COMMAND_STATE.COOKING ? PASSIVE_COLOR : CommandStateColor.cooking)),
          ),
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10),
              widget?.command?.state == COMMAND_STATE.COOKING ?
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

              widget?.command?.state == COMMAND_STATE.SHIPPING ?
              Container(decoration: BoxDecoration(color: CommandStateColor.shipping, borderRadius: BorderRadius.all(Radius.circular(5))), child: Text("SHIPPING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),

              SizedBox(width: 10),
            ],
          )),
          Expanded(flex:0,
            child: Container(child: Icon(FontAwesomeIcons.biking, size: widget?.command?.state == COMMAND_STATE.SHIPPING ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
                color: widget?.command?.state != COMMAND_STATE.SHIPPING ? PASSIVE_COLOR : CommandStateColor.shipping)),
          ),
          Expanded(flex: 2,child: Container()),
        ],
      ),


      Container(height: LINE_HEIGHT, width: LINE_WIDTH, color: CommandStateColor.shipping,  margin: EdgeInsets.only(top:MARGIN, bottom:MARGIN)),

      /* delivered */
      Row(
        children: <Widget>[
          Expanded(flex: 2,child: Container()),
          Container(child: Icon(Icons.check_circle, size: widget?.command?.state == COMMAND_STATE.DELIVERED ? PROGRESS_ICON_SIZE_ACTIVE : PROGRESS_ICON_SIZE_PASSIVE,
              color: widget?.command?.state != COMMAND_STATE.DELIVERED ? PASSIVE_COLOR : CommandStateColor.delivered)
          ),
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10),
              widget?.command?.state == COMMAND_STATE.DELIVERED ?
              Container(decoration: BoxDecoration(color: CommandStateColor.delivered, borderRadius: BorderRadius.all(Radius.circular(5))),   child: Text("DELIVERED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), padding: EdgeInsets.only(top:5, bottom:5, right: 10, left: 10)) : Container(),
            ],
          ))
        ],
      ),

    ]);
  }

  @override
  Future<void> inflateOrderDetails(CommandModel command) async {
    showLoading(false);
    setState(() {
      widget.command = command;
    });

    // this will happen 2 seconds after
    Future.delayed(Duration(seconds: 2), () async {
      if (command.rating < 1 && Utils.within3days(command?.last_update) && command.state == 3 /*within 3 days, you can still do it.*/) {
        // must review.
        /* jump to review pager. */
        Map results = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderFeedbackPage(orderId: widget?.command?.id, presenter: OrderFeedbackPresenter()),
          ),
        );
        if (results != null && results.containsKey('ok')) {
          bool feedBackOk = results['ok'];
          if (feedBackOk) {
            widget.presenter.fetchOrderDetailsWithId(widget.customer, widget?.command?.id);
          }
        }
      } else {
        // can't review or we don't have to review.
//        Toast.show("cant post review", context);
      }
    });
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
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchOrderDetailsWithId(widget.customer, widget.orderId); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchOrderDetailsWithId(widget.customer, widget.orderId); });
  }

  _buildBill() {

    int priceNormalCommand, priceActualCommand, priceTotalToPay, priceNormalDelivery, priceActualDelivery;

    priceNormalCommand = widget.command.food_pricing;

    bool showRemise = true, showDeliveryNormal=true, showFoodNormal= true;

    // depends
    if (widget?.command?.is_preorder == 1) {
      priceTotalToPay = widget.command.preorder_food_pricing;
      priceActualCommand = widget.command.preorder_food_pricing;
      priceActualDelivery = widget.command.preorder_shipping_pricing;
      priceNormalCommand = widget.command.food_pricing;
      priceNormalDelivery = widget.command.shipping_pricing;
    } else if (widget.command.is_promotion == 1) {
      priceTotalToPay = widget.command.promotion_total_pricing;
      priceActualCommand = widget.command.promotion_food_pricing;
      priceActualDelivery = widget.command.promotion_shipping_pricing;
      priceNormalCommand = widget.command.food_pricing;
      priceNormalDelivery = widget.command.shipping_pricing;
    } else if (widget.command.is_promotion == 0 && widget?.command?.is_preorder == 0) {
      priceTotalToPay = widget.command.total_pricing;
      priceActualCommand = widget.command.food_pricing;
      priceActualDelivery = widget.command.shipping_pricing;
      showRemise = false;
      showDeliveryNormal = false;
      showFoodNormal = false;
    }


    return  Card(
        child: Container(padding: EdgeInsets.all(10),
          child: Column(children:<Widget>[
//                      SizedBox(height: 10),
//                      "/web/assets/app_icons/promo_large.gif"
            (int.parse(widget.command?.remise) > 0 ? Container (
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
                  Row( // only show if there is promotion on food
                    children: <Widget>[
                      Text("($priceNormalCommand)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                      SizedBox(width: 5),
                    ],
                  ),
                  Text("$priceActualCommand", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Montant Livraison:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              /* check if there is promotion on Livraison */
              Row(
                children: <Widget>[
                  widget?.command?.is_preorder == 1 || widget?.command?.is_promotion==1 ?
                  Row( // only show if there is pre-order or promotion on the fees of delivery
                    children: <Widget>[
                      Text("($priceNormalDelivery)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15)),
                      SizedBox(width: 5),
                    ],
                  ) : Container(),
                  Text("${priceActualDelivery}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              )
            ]),
            SizedBox(height: 10),
            int.parse(widget.command?.remise) > 0 ?
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Remise:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
              /* check if there is remise */
              Text("-${widget.command?.remise}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CommandStateColor.delivered)),
            ]) : Container(),

            SizedBox(height: 10),
            Center(child: Container(width: MediaQuery.of(context).size.width - 10, color: Colors.black, height:1)),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
              Text("Net à Payer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("${widget?.command?.is_preorder == 0 ? priceTotalToPay : widget.command.preorder_total_pricing}", style: TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 18)),
            ]),
            SizedBox(height: 10),
            (int.parse(widget.command?.remise) > 0 ? Container (
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

  Future<void> _callNumber(String workcontact) async {

    var url = "tel:+228${workcontact}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      Toast.show("Call error", context);
    }
  }

}
