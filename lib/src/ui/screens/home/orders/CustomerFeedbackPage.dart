import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_feedback_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class OrderFeedbackPage extends StatefulWidget {
  static var routeName = "/OrderFeedbackPage";

  OrderFeedbackPresenter presenter;

  int rate = 3;

  int max_rate = 5;

  OrderFeedbackPage({Key key, this.orderId, this.presenter}) : super(key: key);

  int orderId; // = 8744;

  CustomerModel customer;
  CommandModel command;

  @override
  _OrderFeedbackPageState createState() => _OrderFeedbackPageState();
}

class _OrderFeedbackPageState extends State<OrderFeedbackPage>
    implements OrderFeedbackView {
  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  TextEditingController _feedbackTextController = TextEditingController();

  bool isSendingFeedback = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.orderFeedbackView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // if there is an id, then launch here
      if (widget.orderId != null &&
          widget.orderId != 0 &&
          widget.customer != null) {
        widget.presenter.loadOrderDetailsForFeedback(customer, widget.orderId);
      }
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
            icon: Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('note_and_review')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: MyLoadingProgressWidget())
          : (hasNetworkError || hasSystemError
              ? ErrorPage(
                  message: "Network error, please try again.",
                  onClickAction: () => widget.presenter
                      .loadOrderDetailsForFeedback(
                          widget.customer, widget.orderId))
              : SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 30),

                        Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                color: KColors.new_gray,
                                border: new Border.all(
                                    color: KColors.primaryYellowColor,
                                    width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: OptimizedCacheImageProvider(
                                        Utils.inflateLink(
                                            "${widget?.command?.livreur?.pic}"))))),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 15),
                              Text("${widget?.command?.livreur?.name}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: KColors.new_black,
                                      fontSize: 14)),
                              SizedBox(height: 5),
                              Text(
                                  "${AppLocalizations.of(context).translate('shipper')}",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 30),
                              Text(
                                  "${AppLocalizations.of(context).translate('please_give_rating')}",
                                  style: TextStyle(
                                      color: KColors.new_black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // rating starts.
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                      widget.rate >= 1
                                          ? FontAwesomeIcons.solidStar
                                          : FontAwesomeIcons.star,
                                      color: Colors.yellow,
                                      size: 35),
                                  onPressed: () => _starPressed(1)),
                              IconButton(
                                  icon: Icon(
                                      widget.rate >= 2
                                          ? FontAwesomeIcons.solidStar
                                          : FontAwesomeIcons.star,
                                      color: Colors.yellow,
                                      size: 35),
                                  onPressed: () => _starPressed(2)),
                              IconButton(
                                  icon: Icon(
                                      widget.rate >= 3
                                          ? FontAwesomeIcons.solidStar
                                          : FontAwesomeIcons.star,
                                      color: Colors.yellow,
                                      size: 35),
                                  onPressed: () => _starPressed(3)),
                              IconButton(
                                  icon: Icon(
                                      widget.rate >= 4
                                          ? FontAwesomeIcons.solidStar
                                          : FontAwesomeIcons.star,
                                      color: Colors.yellow,
                                      size: 35),
                                  onPressed: () => _starPressed(4)),
                              IconButton(
                                  icon: Icon(
                                      widget.rate >= 5
                                          ? FontAwesomeIcons.solidStar
                                          : FontAwesomeIcons.star,
                                      color: Colors.yellow,
                                      size: 35),
                                  onPressed: () => _starPressed(5)),
                            ]),
                        SizedBox(
                          height: 15,
                        ),
                        Text("${widget.rate}/${widget.max_rate}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                                "${AppLocalizations.of(context).translate('anything_to_say_about_the_service')}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: KColors.new_black)),
                          ],
                        ),
                        SizedBox(height: 10),
                        // text field
                        Container(
                          height: 120,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: KColors.new_gray),
                          padding: EdgeInsets.all(10),
                          child: TextField(
                            maxLines: 5,
                            controller: _feedbackTextController,
                            style: TextStyle(
                                color: KColors.new_black, fontSize: 14),
                            maxLength: 500,
                            textAlign: TextAlign.left,
                            decoration:
                                InputDecoration.collapsed(hintText: "..."),
                          ),
                        ),

                        SizedBox(height: 50),

                        GestureDetector(
                          onTap: () => _sendReview(),
                          child: Container(
                            decoration: BoxDecoration(
                                color: KColors.primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(15),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context).translate('submit')}"
                                      ?.toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.white),
                                ),
                                isSendingFeedback
                                    ? Row(
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          SizedBox(
                                              child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white)),
                                              height: 15,
                                              width: 15),
                                        ],
                                      )
                                    : Container(),
                              ],
                            )),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ]),
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
    widget.presenter.sendFeedback(
        widget.customer, widget.orderId, reviewStars, reviewMessage);
  }

  @override
  void inflateOrderDetails(CommandModel command) {
    xrint("images ${command?.restaurant_entity?.pic}");
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
  void systemError() {}

  @override
  void networkError() {}

  @override
  void sendFeedbackSuccess() {
    _showDialog(
      okBackToHome: false,
      icon: Icon(
        Icons.check,
        color: Colors.blue,
      ),
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
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: <Widget>[
              OutlinedButton(
                child: new Text("OK",
                    style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  if (!okBackToHome) {
                    Navigator.of(context).pop({'ok': true});
                    Navigator.of(context).pop({'ok': true});
                  } else
                    Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()),
                        (r) => false);
                },
              ),
            ]);
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
