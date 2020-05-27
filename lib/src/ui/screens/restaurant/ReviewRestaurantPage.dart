import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/contracts/restaurant_review_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';



class ReviewRestaurantPage extends StatefulWidget {

  static var routeName = "/ReviewRestaurantPage";

  RestaurantReviewPresenter presenter;

  RestaurantModel restaurant;

  CustomerModel customer;

  int rate;

  int max_rate = 5;

  ReviewRestaurantPage({Key key, this.rate = 1, this.presenter, this.restaurant}) : super(key: key);

  @override
  _ReviewRestaurantPageState createState() => _ReviewRestaurantPageState();
}

class _ReviewRestaurantPageState extends State<ReviewRestaurantPage> implements RestaurantReviewView {

  bool _isReviewSendingLoading = false;

  TextEditingController _reviewTextController = TextEditingController();

  @override
  void initState() {

    super.initState();
    this.widget.presenter.restaurantReviewView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: KColors.primaryYellowColor,
          title: Text("REVIEW")
      ),
        body: SingleChildScrollView(
          child: Column(
            children: (<Widget>[
              // tell us what to do
              SizedBox(height:10),
              Container(margin: EdgeInsets.only(top:40, right: 20, left:20), decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(10), child: Text("Please give the restaurant a review about. We really appreciate it. \nThank you", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
              SizedBox(height:10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                IconButton(icon: Icon(widget.rate >= 1 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(1)),
                IconButton(icon: Icon(widget.rate >= 2 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(2)),
                IconButton(icon: Icon(widget.rate >= 3 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(3)),
                IconButton(icon: Icon(widget.rate >= 4 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(4)),
                IconButton(icon: Icon(widget.rate >= 5 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(5)),
              ]),

// message field
              SizedBox(height:10),

              Container (margin: EdgeInsets.only(left:20, right:20, top:20),decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color:Colors.grey.shade200), padding: EdgeInsets.all(10),
                  child: TextField(controller: _reviewTextController, style: TextStyle(color: Colors.black, fontSize: 16), maxLength: 500, textAlign: TextAlign.left,
                    decoration: InputDecoration.collapsed(hintText: "Please give ${widget?.restaurant?.name?.toUpperCase()} a review..."),
                  )),
              SizedBox(height:10),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color: Colors.white,
                      child: Row(mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("SEND THE REVIEW ${widget.rate}/${widget.max_rate}", style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                          _isReviewSendingLoading ?  Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor)), height: 15, width: 15) ,
                            ],
                          )  : Container(),
                        ],
                      ), onPressed: () => _sendReview()),
                ],
              ),

              SizedBox(height:50),
            ])
          ),
        )
    );
  }

  @override
  void networkError() {
    mToast("Network error. Please try again");
  }

  @override
  void reviewingSuccess() {

   // thank you for the review, and pop.
    _showDialog(
      okBackToHome: false,
      icon: Icon(Icons.check, color: Colors.blue,),
      message: "Thank you for submitting your review.",
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
                  Navigator.of(context).pop({'ok': true});
                  Navigator.of(context).pop({'ok': true});
                },
              ),
            ]
        );
      },
    );
  }


  @override
  void showSendingReviewLoading(bool isLoading) {
   setState(() {
     _isReviewSendingLoading = isLoading;
   });
  }

  @override
  void systemError() {
  mToast("There was an error. Please try again");
  }

  void _starPressed(int position) {
    setState(() {
      widget.rate = position;
    });
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _sendReview() {
    String reviewMessage = _reviewTextController.text;
    int reviewStars = widget.rate;
    widget.presenter.reviewRestaurant(widget.customer, widget.restaurant, reviewStars, reviewMessage);
  }
}
