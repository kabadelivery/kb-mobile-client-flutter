import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_review_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

class ReviewRestaurantPage extends StatefulWidget {
  static var routeName = "/ReviewRestaurantPage";

  RestaurantReviewPresenter presenter;

  ShopModel restaurant;

  CustomerModel customer;

  int rate;

  int max_rate = 5;

  ReviewRestaurantPage(
      {Key key, this.rate = 1, this.presenter, this.restaurant})
      : super(key: key);

  @override
  _ReviewRestaurantPageState createState() => _ReviewRestaurantPageState();
}

class _ReviewRestaurantPageState extends State<ReviewRestaurantPage>
    implements RestaurantReviewView {
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
          actions: [Container(width: 40)],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('review')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
              children: (<Widget>[
            // tell us what to do
            SizedBox(height: 30),
            Center(
                child: Text(
                    "${AppLocalizations.of(context).translate('review_us')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              IconButton(
                  icon: Icon(
                      widget.rate >= 1
                          ? FontAwesomeIcons.solidStar
                          : FontAwesomeIcons.star,
                      color: KColors.primaryYellowColor,
                      size: 40),
                  onPressed: () => _starPressed(1)),
              IconButton(
                  icon: Icon(
                      widget.rate >= 2
                          ? FontAwesomeIcons.solidStar
                          : FontAwesomeIcons.star,
                      color: KColors.primaryYellowColor,
                      size: 40),
                  onPressed: () => _starPressed(2)),
              IconButton(
                  icon: Icon(
                      widget.rate >= 3
                          ? FontAwesomeIcons.solidStar
                          : FontAwesomeIcons.star,
                      color: KColors.primaryYellowColor,
                      size: 40),
                  onPressed: () => _starPressed(3)),
              IconButton(
                  icon: Icon(
                      widget.rate >= 4
                          ? FontAwesomeIcons.solidStar
                          : FontAwesomeIcons.star,
                      color: KColors.primaryYellowColor,
                      size: 40),
                  onPressed: () => _starPressed(4)),
              IconButton(
                  icon: Icon(
                      widget.rate >= 5
                          ? FontAwesomeIcons.solidStar
                          : FontAwesomeIcons.star,
                      color: KColors.primaryYellowColor,
                      size: 40),
                  onPressed: () => _starPressed(5)),
            ]),

// message field
            SizedBox(height: 10),

            Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.grey.shade200),
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _reviewTextController,
                  style: TextStyle(color: Colors.black, fontSize: 13),
                  maxLines: 5,
                  minLines: 4,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration.collapsed(
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      hintText:
                          "${AppLocalizations.of(context).translate('please_give')} ${widget?.restaurant?.name?.toUpperCase()} ${AppLocalizations.of(context).translate('a_review')}"),
                )),
            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () => _sendReview(),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.circular(5)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            Utils.capitalize("${AppLocalizations.of(context).translate('send_review')} ${widget.rate}/${widget.max_rate}"),
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 12, color: Colors.white)),
                        _isReviewSendingLoading
                            ? Row(
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                      height: 15,
                                      width: 15),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ])),
        ));
  }

  @override
  void networkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  @override
  void reviewingSuccess() {
    // thank you for the review, and pop.
    _showDialog(
      okBackToHome: false,
      icon: Icon(
        Icons.check,
        color: Colors.blue,
      ),
      message: "${AppLocalizations.of(context).translate('reviewing_success')}",
    );
  }

  void _showDialog({Icon icon, var message, bool okBackToHome = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(height: 80, width: 80, child: icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 13))
            ]),
            actions: <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}",
                    style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop({'ok': true});
                  Navigator.of(context).pop({'ok': true});
                },
              ),
            ]);
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
    mToast("${AppLocalizations.of(context).translate('system_error')}");
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
    widget.presenter.reviewRestaurant(
        widget.customer, widget.restaurant, reviewStars, reviewMessage);
  }
}
