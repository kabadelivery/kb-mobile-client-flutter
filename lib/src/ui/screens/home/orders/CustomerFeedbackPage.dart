import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/order_feedback_contract.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderFeedbackPage extends StatefulWidget {

  static var routeName = "/OrderFeedbackPage";

  OrderFeedbackPresenter presenter;

  int rate = 3;

  int max_rate = 5;


  OrderFeedbackPage ({Key key, this.orderId, this.presenter}) : super(key: key);

  int orderId; // = 8744;

  CustomerModel customer;
  CommandModel command;

  @override
  _OrderFeedbackPageState createState() => _OrderFeedbackPageState();
}

class _OrderFeedbackPageState extends State<OrderFeedbackPage> implements OrderFeedbackView {


  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  TextEditingController _feedbackTextController  = TextEditingController();

  bool isSendingFeedback = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   widget.presenter.orderFeedbackView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
      if (widget.orderId != null && widget.orderId != 0 && widget.customer != null) {
        widget.presenter.loadOrderDetailsForFeedback(customer, widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      isLoading ? Center(child: CircularProgressIndicator()) : (
          hasNetworkError || hasSystemError ? ErrorPage(message: "Network error, please try again.", onClickAction: ()=>  widget.presenter.loadOrderDetailsForFeedback(widget.customer, widget.orderId)) :
          Stack(
            children: <Widget>[
              Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: KColors.mBlue,
                /*  decoration: BoxDecoration(image: new DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(Utils.inflateLink("/web/assets/app_icons/kabachat.jpg"))
          )*/
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[

                    Container(margin: EdgeInsets.only(left:20,right:20),child: Text("We need to know what you think about our services to serve you better. Would you please rate us?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),

                    SizedBox(height:20),

                    Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[

                      // delivery man
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                  height:90, width: 90,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: new Border.all(color: Colors.white, width: 2),
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(Utils.inflateLink("${widget?.command?.livreur?.pic}"))
                                      )
                                  )
                              ),
                              Container(margin: EdgeInsets.only(left:10,right:10),child: Text(" X ", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)),
                              // restaurant picture
                              Container(
                                  height:90, width: 90,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      border: new Border.all(color: Colors.white, width: 2),
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(Utils.inflateLink(widget?.command?.restaurant_entity?.pic))
                                      )
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),

                    Column(
                      children: <Widget>[
                        SizedBox(height:15),
                        Row(
                          children: <Widget>[
                            Container(width: MediaQuery.of(context).size.width/2,
                                padding: EdgeInsets.all(10),
                                child: Text("KABA DELIVERY",
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight
                                            .bold))),

                            Container(width: MediaQuery.of(context).size.width/2,
                                padding: EdgeInsets.all(10),
                                child: Text("${widget?.command?.restaurant_entity?.name}",
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight
                                            .bold))),
                          ],
                        ),

                      ],
                    ),

                    SizedBox(height:20),

                    // rating starts.
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                      IconButton(icon: Icon(widget.rate >= 1 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(1)),
                      IconButton(icon: Icon(widget.rate >= 2 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(2)),
                      IconButton(icon: Icon(widget.rate >= 3 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(3)),
                      IconButton(icon: Icon(widget.rate >= 4 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(4)),
                      IconButton(icon: Icon(widget.rate >= 5 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(5)),
                    ]),
                    SizedBox(height:20),
                    // text field
                    Container (margin: EdgeInsets.only(left:20, right:20, top:20),decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200), padding: EdgeInsets.all(10),
                      child: TextField(controller: _feedbackTextController, style: TextStyle(color: Colors.black, fontSize: 16), maxLength: 500, textAlign: TextAlign.left,
                        decoration: InputDecoration.collapsed(hintText: "Please give us a review..."),
                      ),
                    ),

                    SizedBox(height:30),


                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color: Colors.white,
                            child: Row(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("SEND THE REVIEW ${widget.rate}/${widget.max_rate}", style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                                isSendingFeedback ?  Row(
                                  children: <Widget>[
                                    SizedBox(width: 10),
                                    SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor)), height: 15, width: 15) ,
                                  ],
                                )  : Container(),
                              ],
                            ), onPressed: () => _sendReview()),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          )),
    );
  }

  void _starPressed(int position) {

    setState(() {
      widget.rate = position;
    });
  }

  _sendReview() {

    String reviewMessage = _feedbackTextController.text;
    int reviewStars = widget.rate;
    widget.presenter.sendFeedback(widget.customer, widget.orderId, reviewStars, reviewMessage);
  }

  @override
  void inflateOrderDetails(CommandModel command) {

    print("images ${command?.restaurant_entity?.pic}");
    setState(() {
      widget.command = command;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  @override
  void systemError() {
  }

  @override
  void networkError() {
  }


  @override
  void sendFeedbackSuccess() {

    _showDialog(
      okBackToHome: false,
      icon: Icon(Icons.check, color: Colors.blue,),
      message: "Thank you for submitting your review.",
    );
  }

  @override
  void sendFeedbackError(int errorCode) {

    // feedback network error.
    _showDialog(
      okBackToHome: false,
      icon: Icon(Icons.error, color: KColors.primaryColor),
      message: "Feed back submitting error. Please try again.",
    );
  }



  void _showDialog(
      {Icon icon, var message, bool okBackToHome = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions: <Widget>[
              OutlineButton(
                child: new Text(
                    "OK", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  if (!okBackToHome) {
                    Navigator.of(context).pop({'ok': true});
                    Navigator.of(context).pop({'ok': true});
                  } else
                    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()), (
                        r) => false);
                },
              ),
            ]
        );
      },
    );
  }

  @override
  void sendFeedBackLoading(bool issending) {
    setState(() {
      isSendingFeedback = issending;
    });
  }


}
