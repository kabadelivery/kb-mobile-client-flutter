import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/contracts/order_details_contract.dart';
import 'package:kaba_flutter/src/contracts/order_feedback_contract.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderFeedbackPage extends StatefulWidget {

  static var routeName = "/CustomerFeedbackPage";

  OrderFeedbackPresenter presenter;

  int rate = 1;


  OrderFeedbackPage ({Key key, this.orderId, this.presenter}) : super(key: key);

  int orderId = 8744;

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

  bool isConnecting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    widget.presenter.orderDetailsView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
       if (widget.orderId != null && widget.orderId != 0 && widget.command == null && widget.customer != null) {
        widget.presenter.loadOrderDetailsForFeedback(customer, widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                                      image: CachedNetworkImageProvider(Utils.inflateLink("/employee_picture/5c101acec8057058989430.jpg"))
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
//                      SizedBox(height:50)
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
                            child: Text("ESKAPADE DU CHEF",
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
                            Text("SEND THE REVIEW", style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                            isConnecting ?  Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
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
      ),
    );
  }

  void _starPressed(int position) {

    setState(() {
      widget.rate = position;
    });

  }

  _sendReview() {


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
  }

  @override
  void systemError() {
  }

  @override
  void networkError() {
  }

  @override
  void sendFeedbackError() {
  }

  @override
  void sendFeedbackSuccess() {
  }

}
