import 'package:KABA/src/models/VoucherModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class MyVoucherMiniWidget extends StatefulWidget {

  VoucherModel voucher;

  MyVoucherMiniWidget({this.voucher});

  @override
  _MyVoucherMiniWidgetState createState() {
    return _MyVoucherMiniWidgetState();
  }
}


class _MyVoucherMiniWidgetState extends State<MyVoucherMiniWidget> {

  /* restaurant voucher gradient */
  var restaurantVoucherBg = [Color(0xFFEAEB12), Color(0xFFF1AA00)];
  /* delivery voucher gradient */
  var deliveryVoucherBg = [Color(0xFFCC1641), Color(0xFFFF7E9C)];
  /* all voucher gradient */
  var bothVoucherBg = [Color(0xFFFFFFFF), Color(0xFFFFFFF0)];

  var textColorWhite = Color(0xFFFFFFFF);
  var textColorBlack = Color(0xFF000000);
  var textColorYellow = KColors.colorMainYellow;
  var textColorRed = KColors.colorCustom;


  @override
  void initState() {
    super.initState();

    // according to the type, we set a dark and clear equivalent. --> yellow and red text

    // delivery -> money_price:white, restaurant_name:dark, code:yellow(food)

    // restaurant ->  money_price:red, restaurant_name:dark, code:white

    // both ->  money_price:yellow, restaurant_name:black, code:red

  }

  @override
  Widget build(BuildContext context) {
    return
      Card(margin: EdgeInsets.only(left:10,right:10,top:10),
//              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Container(

            /* ACCORDING TO THE MODEL THE GRADIENT IS ALSO DIFFERENT */
           decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
               colors: widget.voucher.category == 1 ? restaurantVoucherBg : (widget.voucher.category == 2 ? deliveryVoucherBg : bothVoucherBg),
               tileMode: TileMode.repeated, // repeats the gradient over the canvas
             ),
           )
            ,
            child: InkWell(
                onTap: () => _jumpToVoucherDetails(),
                child: SizedBox(
                  child: Stack(
                    children: <Widget>[

                      /* ACCORDING TO THE MODEL THE ICON (FOOD, DELIVERY, ALL) IS ALSO DIFFERENT */
                      Positioned(bottom:10,right:10,child: Icon(Icons.directions_bike)),

                      Container(
                          margin: EdgeInsets.only(left:20, right:20),
                          child: Column(children: <Widget>[
                            SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[

                                /* JUST IN CASE THE VOUCHER IS RESTAURANT BASED, WE SET UP THE NAME HERE. */
                                Text("${widget.voucher.getRestaurantsName() == null ? "ALL" : widget.voucher.getRestaurantsName()}".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[

                                  /* JUST SHOW IT */
                                  Text("${widget.voucher.subscription_code}".toUpperCase(), style: TextStyle(fontSize: 18)),
                                  Text("-${widget.voucher.value}${widget.voucher.type == 1 ? "FCFA" : "%"}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: KColors.primaryColor))
                                ]
                            ),
                            SizedBox(height: 10),

                            /* SHOW EXPIRY DATE */
                            Text("Expire le 20/07", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            SizedBox(height: 10),
                          ])
                      ),
                    ],
                  ),
                )),
          ));

  }

  _jumpToVoucherDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailsPage(),
      ),
    );
  }

}

class VoucherListItemClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    double teethDeepth = 30;
    path.lineTo(teethDeepth, teethDeepth*0.60);
    path.lineTo(0, teethDeepth*0.60);
    path.lineTo(teethDeepth, teethDeepth);
    path.lineTo(0, teethDeepth);
    path.lineTo(teethDeepth, teethDeepth*1.5);
    path.lineTo(0, teethDeepth*1.5);
    path.lineTo(teethDeepth, teethDeepth*2);
    path.lineTo(0, teethDeepth*2);
    path.lineTo(teethDeepth, teethDeepth*2.5);
    path.lineTo(0, teethDeepth*2.5);
    path.lineTo(teethDeepth, teethDeepth*3);
    path.lineTo(0, teethDeepth*3);
    path.lineTo(teethDeepth, teethDeepth*3.5);
    path.lineTo(0, teethDeepth*3.5);
    path.lineTo(teethDeepth, teethDeepth*4);
    path.lineTo(0, teethDeepth*4);
    path.lineTo(teethDeepth, teethDeepth*4.5);
    path.lineTo(0, teethDeepth*4.5);

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip (VoucherListItemClipper oldClipper) => true;

}