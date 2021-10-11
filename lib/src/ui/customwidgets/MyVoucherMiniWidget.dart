import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class MyVoucherMiniWidget extends StatefulWidget {

  VoucherModel voucher;

  bool pick;

  bool subscribeSuccess;

  bool isForOrderConfirmation;

  MyVoucherMiniWidget({this.voucher, this.pick = false, this.subscribeSuccess = false, isForOrderConfirmation = false});

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
  var bothVoucherBg = [ Color(0xFFEEEEEE), Color(0xFFFFFFFF)];

  var textColorWhite = Color(0xFFFFFFFF);
  var textColorBlack = Color(0xFF000000);
  var textColorYellow = KColors.colorMainYellow;
  var textColorRed = KColors.colorCustom;

  var restaurantNameColor, priceColor, voucherCodeColor, expiresDateColor, typeIconColor;

  var voucherIcon = Icons.not_interested;

  @override
  void initState() {
    super.initState();

    // according to the type, we set a dark and clear equivalent. --> yellow and red text

    // delivery -> money_price:white, restaurant_name:dark, code:yellow(food)
    // restaurant ->  money_price:red, restaurant_name:dark, code:white
    // both ->  money_price:yellow, restaurant_name:black, code:red

    switch(widget.voucher.type){
      case 1: // restaurant (yellow background)
        restaurantNameColor = textColorWhite;
        priceColor = textColorRed;
        voucherCodeColor = textColorRed;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorBlack;
        voucherIcon = FontAwesomeIcons.hamburger;
        break;
      case 2: // delivery (red background)
        restaurantNameColor = textColorBlack;
        priceColor = textColorYellow;
        voucherCodeColor = textColorWhite;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorWhite;
        voucherIcon = FontAwesomeIcons.biking;
        break;
      case 3: // both (white bg)
        restaurantNameColor = textColorBlack;
        priceColor = textColorYellow;
        voucherCodeColor = textColorRed;
        expiresDateColor = textColorBlack;
        typeIconColor = textColorBlack;
        voucherIcon = FontAwesomeIcons.bullseye;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

//    foregroundDecoration: BoxDecoration(
//      color: Colors.grey,
//      backgroundBlendMode: BlendMode.saturation,
//    ),

    return widget.voucher.use_count-widget.voucher.already_used_count == 0 || Utils.isEndDateReached(widget?.voucher?.end_date) ?
    Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: ClipPath(
          clipper: VoucherListItemClipper(),
          child: Card(margin: EdgeInsets.only(left:10,right:10,top:10),
//              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: Container(
                /* ACCORDING TO THE MODEL THE GRADIENT IS ALSO DIFFERENT */
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                    colors: widget.voucher.type == 1 ? restaurantVoucherBg : (widget.voucher.type == 2 ? deliveryVoucherBg : bothVoucherBg),
                    tileMode: TileMode.repeated, // repeats the gradient over the canvas
                  ),
                )
                ,
                child: InkWell(
                    onLongPress: () => _onLongPressVoucher(),
                    onTap: () => _tapVoucher(),
                    child: Column(
                      children: [
                        Stack(
                          children: <Widget>[
                            /* ACCORDING TO THE MODEL THE ICON (FOOD, DELIVERY, ALL) IS ALSO DIFFERENT */
                            Positioned(bottom:10,right:10,child: Icon(voucherIcon)),
                            Container(
                                margin: EdgeInsets.only(left:20, right:20),
                                child: Column(children: <Widget>[
                                  SizedBox(height: 10),
                                  Row(mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      /* JUST IN CASE THE VOUCHER IS RESTAURANT BASED, WE SET UP THE NAME HERE. */
                                      Text("${widget.voucher.trade_name}", style: TextStyle(color: restaurantNameColor, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        /* JUST SHOW IT */
                                        Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons.code, color: voucherCodeColor, size: 15),
                                            SizedBox(width:10),
                                            Text("${widget.voucher.subscription_code}".toUpperCase(), style: TextStyle(color: voucherCodeColor,fontSize: 16, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                       widget.voucher.category == 1 ?
                                       Text("-${widget.voucher.value}%", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: priceColor))
                                           :
                                       /* superposing two stuffs */
                                       Column(
                                         children: [
                                           Text("-${widget.voucher.value}F", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: priceColor)),
                                           Container(width:40, height: 3, color: Colors.white),
                                           Text("-${widget.voucher.value}F", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: priceColor)),
                                         ],
                                       )
                                      ]
                                  ),
                                  SizedBox(height: 10),
                                  /* SHOW EXPIRY DATE */
                                  Text("${AppLocalizations.of(context).translate('coupon_use_before')} ${Utils.timeStampToDate(widget?.voucher?.end_date)}", textAlign: TextAlign.center, style: TextStyle(color: expiresDateColor,fontSize: 12)),
                                  SizedBox(height: 10),
                                ])
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top:5,bottom:5,right:5,left:5),
                          color: widget.voucher.type == 1 ? restaurantVoucherBg[0] : (widget.voucher.type == 2 ? deliveryVoucherBg[0] : bothVoucherBg[0]), //.withAlpha(100),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                            Text("${AppLocalizations.of(context).translate('disponible')} (${widget.voucher.use_count-widget.voucher.already_used_count})", style: TextStyle(fontWeight: FontWeight.bold, color: voucherCodeColor)),
                            Text("${AppLocalizations.of(context).translate('utilisation')} (${widget.voucher.already_used_count})", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ]),
                        )
                      ],
                    )),
              )),
        )
    ) :
    Shimmer(
      duration: Duration(seconds: 2), //Default value
      color: Colors.white, //Default value
      enabled: true, //Default value
      direction: ShimmerDirection.fromLTRB(),  //Default Value
      child: ClipPath(
        clipper: VoucherListItemClipper(),
        child: Card(margin: EdgeInsets.only(left:10,right:10,top:10),
//              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Container(
              /* ACCORDING TO THE MODEL THE GRADIENT IS ALSO DIFFERENT */
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                  colors: widget.voucher.type == 1 ? restaurantVoucherBg : (widget.voucher.type == 2 ? deliveryVoucherBg : bothVoucherBg),
                  tileMode: TileMode.repeated, // repeats the gradient over the canvas
                ),
              )
              ,
              child: InkWell(
                  onLongPress: () => _onLongPressVoucher(),
                  onTap: () => _tapVoucher(),
                  child: Column(
                    children: [
                      Stack(
                        children: <Widget>[
                          /* ACCORDING TO THE MODEL THE ICON (FOOD, DELIVERY, ALL) IS ALSO DIFFERENT */
                          Positioned(bottom:10,right:10,child: Icon(voucherIcon)),
                          Container(
                              margin: EdgeInsets.only(left:20, right:20),
                              child: Column(children: <Widget>[
                                SizedBox(height: 10),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    /* JUST IN CASE THE VOUCHER IS RESTAURANT BASED, WE SET UP THE NAME HERE. */
                                    Text("${widget.voucher.trade_name}", style: TextStyle(color: restaurantNameColor, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      /* JUST SHOW IT */
                                      Row(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.code, color: voucherCodeColor, size: 15),
                                          SizedBox(width:10),
                                          Text("${widget.voucher.subscription_code}".toUpperCase(), style: TextStyle(color: voucherCodeColor,fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Text("-${widget.voucher.value}${widget.voucher.category == 1 ? "%" : "F"}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: priceColor))
                                    ]
                                ),
                                SizedBox(height: 10),
                                /* SHOW EXPIRY DATE */
                                Text("${AppLocalizations.of(context).translate('coupon_use_before')} ${Utils.timeStampToDate(widget?.voucher?.end_date)}", textAlign: TextAlign.center, style: TextStyle(color: expiresDateColor,fontSize: 12)),
                                SizedBox(height: 10),
                              ])
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top:5,bottom:5,right:5,left:5),
                        color: widget.voucher.type == 1 ? restaurantVoucherBg[0] : (widget.voucher.type == 2 ? deliveryVoucherBg[0] : bothVoucherBg[0]), //.withAlpha(100),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                          Text("${AppLocalizations.of(context).translate('disponible')} (${widget.voucher.use_count-widget.voucher.already_used_count})", style: TextStyle(fontWeight: FontWeight.bold, color: voucherCodeColor)),
                          Text("${AppLocalizations.of(context).translate('utilisation')} (${widget.voucher.already_used_count})", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ]),
                      )
                    ],
                  )),
            )),
      ),
    );

  }

  _jumpToVoucherDetails() {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailsPage(voucher: widget.voucher),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            VoucherDetailsPage(voucher: widget.voucher),
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

  _onLongPressVoucher() {
    if (widget.pick || widget.isForOrderConfirmation) {
      _jumpToVoucherDetails();
    }
  }

  _tapVoucher() {

    if (widget?.isForOrderConfirmation == true) {

      return;
    }

    if (widget.pick) {
      // go back
      Navigator.of(context).pop({'voucher': widget.voucher});
    } else {
      if (widget.subscribeSuccess) {
        Navigator.of(context).pop();
      }
      _jumpToVoucherDetails();
    }
  }



}

class VoucherListItemClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    double teethDeepth = 15;
//    path.lineTo(0, teethDeepth*0.60);
    path.lineTo(0, teethDeepth*0.5);
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
    path.lineTo(teethDeepth, teethDeepth*5);
    path.lineTo(0, teethDeepth*5);
    path.lineTo(teethDeepth, teethDeepth*5.5);
    path.lineTo(0, teethDeepth*5.5);
    path.lineTo(teethDeepth, teethDeepth*6);
    path.lineTo(0, teethDeepth*6);
    path.lineTo(teethDeepth, teethDeepth*6.5);
    path.lineTo(0, teethDeepth*6.5);

//    path.lineTo(0, teethDeepth*4);
//    path.lineTo(teethDeepth, teethDeepth*4.5);
//    path.lineTo(0, teethDeepth*4.5);

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip (VoucherListItemClipper oldClipper) => true;

}