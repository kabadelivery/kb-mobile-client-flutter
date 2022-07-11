import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';


class VoucherDetailsPage extends StatefulWidget {

  static var routeName = "/VoucherDetailsPage";

  VoucherModel voucher;

  bool food_see_more;

  VoucherDetailsPage({Key key, this.title, this.voucher, this.food_see_more = false}) : super(key: key);

  final String title;

  @override
  _VoucherDetailsPageState createState() => _VoucherDetailsPageState();
}

class _VoucherDetailsPageState extends State<VoucherDetailsPage> {

  var voucherIcon = Icons.not_interested;

  var scaffoldColor = KColors.primaryColor;

  var _scaffoldGlobalKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch(widget.voucher.type){
      case 1: // restaurant (yellow background)
        voucherIcon = FontAwesomeIcons.hamburger;
        scaffoldColor = KColors.primaryYellowColor;
        break;
      case 2: // delivery (red background)
        voucherIcon = FontAwesomeIcons.biking;
        scaffoldColor = KColors.primaryColor;
        break;
      case 3: // both (white bg)
        voucherIcon = FontAwesomeIcons.bullseye;
        scaffoldColor = KColors.darkish.withAlpha(100);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: scaffoldColor,  key: _scaffoldGlobalKey,
        appBar: AppBar( brightness: Brightness.light,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
            backgroundColor: Colors.white,
            title: Text("${AppLocalizations.of(context).translate('voucher_details')}", style:TextStyle(color:KColors.primaryColor))),
        body:  _buildVoucherDetailsPage(null)
    );
  }

  Widget _buildVoucherDetailsPage(VoucherDetailsPage data) {
    return SingleChildScrollView(
      child:   ClipPath(
        clipper: VoucherClipper(),
        child: Card(
          margin: EdgeInsets.only(left:40, right: 40, top: 30, bottom:30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
            child: Column(
                children: <Widget>[
                  SizedBox(height:10),
                  Text("${AppLocalizations.of(context).translate('voucher_')}", style: KStyles.hintTextStyle_gray),
                  SizedBox(height:10),
                  /* code qr; s'il est possible de partager cela */
                  Stack(
                    children: <Widget>[
                      Container(height: 160, width: 160,
                          child: QrImage(
                            data: '${_getVoucherShareLink()}',
                            version: QrVersions.auto,
                            size: 160,
                            gapless: false,
                            foregroundColor: Colors.black,
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: Size(35, 35),
                            ),
                          )
                      ),
                      /*   Positioned(left: 64, top:64,child:
                      Container(
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              border: Border.all(width: 2, color: KColors.primaryYellowColor), color: Colors.white),
                          padding: EdgeInsets.all(6),
                          child: Center(child: Icon(voucherIcon, color: KColors.primaryColor, size: 16)))),*/
                    ],
                  ),

                  SizedBox(height: 10),

                 /* Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    Text('-${widget.voucher.value}',  style: new TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 24)),
                    Text(" ${widget.voucher.category == 1 ?  "%" : "${AppLocalizations.of(context).translate('currency')}"}", style: TextStyle(fontSize: 14, color: KColors.primaryColor)),
                  ]),*/
          _buildCFAPriceWidget(),


                  /* details du restaurant */
                  SizedBox(height: 20),
                  Text("${widget.voucher?.trade_name}".toUpperCase(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  widget.voucher?.description == null ? Container() : Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                     Text("${widget.voucher?.description == null ? "" : widget.voucher?.description}",
                          textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryColor))]),
//                   Column(
//                     children: <Widget>[
//                       SizedBox(height: 10),
//                       widget.voucher.products?.length == null || widget.voucher.products?.length == 0 ?
//                       Text("${AppLocalizations.of(context).translate('voucher_for_spec_foods_all')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryColor),)
//                           :
//                       Text("${AppLocalizations.of(context).translate('voucher_for_spec_foods')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray_11),
//                       /* start a mini food list .. */
// //                      Text("WING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATEWING'S 10PCS / RIZ CURRY / WINGS' 5PCS / CUSTOM PLATE", textAlign: TextAlign.center, style: TextStyle(fontSize: 12,color: KColors.primaryYellowColor)),
//                       //  _miniFoodWidget(ShopProductModel.randomFood())
//                     ]/*..add(InkWell(onTap: (){setState(() {
//                       widget.food_see_more = true;
//                     });},
//                       child: Container(margin: EdgeInsets.only(top:10),
//                         child: Text(
//                           "${_miniFoodsText(widget?.voucher?.products)}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: KColors.primaryYellowColor, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ))*/
//                     /*..addAll(
//                         List.generate(widget?.voucher?.products?.length, (int index){
//                           return _miniFoodWidget(widget.voucher.products[index]);
//                         })
//                     )*/,
//                   ),
                  SizedBox(height: 20),
                  Column(
                    children: <Widget>[
                      Text("${AppLocalizations.of(context).translate('voucher_code')}", style: KStyles.hintTextStyle_gray),
                    ],
                  ),
                  SizedBox(height:10),
                  Container(height: 1, color: Colors.grey.withAlpha(100)),
                  /* repas concernes */
                  Container(
//                    color: Colors.yellow,
                    padding: EdgeInsets.only(top:20, bottom:20),
                    child:
                    InkWell(
                        onTap: ()=>_copyIntoClipboard("${widget.voucher.subscription_code}".toUpperCase()),
                        child: Text('${widget.voucher.subscription_code}'.toUpperCase(),textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                  Container(height: 1, color: Colors.grey.withAlpha(100)),
                  /* debut d'utilisation */
                  SizedBox(height: 20),
                  /* use counts for me \ category of voucher \ type of voucher \ */
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            children: <Widget>[
                              Text("${AppLocalizations.of(context).translate('available_since')}", style: TextStyle(color: Colors.green, fontSize: 13)),
                              Text("${Utils.timeStampToDate(widget.voucher.start_date)}",style: TextStyle(fontSize: 13))
                            ]
                        ),
                        Column(
                            children: <Widget>[
                              Text("${AppLocalizations.of(context).translate('expiry_date')}",  style: TextStyle(color: KColors.primaryColor, fontSize: 13)),
                              Text("${Utils.timeStampToDate(widget.voucher.end_date)}",style: TextStyle(fontSize: 13))
                            ]
                        )
                      ]),
                  /* powered by */
                  SizedBox(height: 20),
                  Text('${AppLocalizations.of(context).translate('powered_by_kaba_tech')}', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ]
            ),
          ),
        ),
      ),
    );
  }

  _buildCFAPriceWidget() {
    return
      widget.voucher.category == 1 ?
      Text("-${widget.voucher.value}%", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: KColors.primaryColor))
          :
      Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("-${(widget.voucher.use_count-widget.voucher.already_used_count)*widget.voucher.value}F", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: KColors.primaryColor)),
          Container(width:110, height: 2, color: Colors.black, margin: EdgeInsets.only(bottom:1),),
          Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("* ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black)),
              Text("-${widget.voucher.value}F X ${widget.voucher.use_count-widget.voucher.already_used_count}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black)),
            ],
          ),
        ],
      );
  }

  String _getVoucherShareLink (){
    return ServerConfig.APP_SERVer+"/voucher/"+widget.voucher.qr_code;
  }

  void _copyIntoClipboard(String codePromo) {
    // ClipboardManager.copyToClipBoard(codePromo).then((result) {
    //   mToast("${codePromo} ${AppLocalizations.of(context).translate('copied_c')}");
    // });

    FlutterClipboard.copy(codePromo).then((value) {
      mToast("${codePromo} ${AppLocalizations.of(context).translate('copied_c')}");
    });
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _miniFoodWidget(ShopProductModel food) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("${food?.name.toUpperCase()}", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /*prix*/
                  Row(children: <Widget>[
                    Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 12, fontWeight: FontWeight.normal)),
                    Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 8, fontWeight: FontWeight.normal)),
                  ]),
                ],
              ),
            ),
          ],
        ),
        Container(height:1, margin: EdgeInsets.only(top:5, bottom:5), color: Colors.green),
      ],
    );
  }

  _miniFoodsText(List<ShopProductModel> products) {

    if (products?.length > 20 && widget.food_see_more == false) {
      return "${products?.length} ${AppLocalizations.of(context).translate('foods_')}\n\n> See More <";
    } else {
      String res = "";
      for (int i = 0; i < products?.length; i++) {
        res += "${products[i]?.name}(${products[i]?.price})";
        if (i != products?.length - 1) {
          res += "\n";
        }
      }
      return res.toUpperCase();
    }
  }
}

class VoucherClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
//    path.lineTo(0.0, size.height);
//    path.arcToPoint(Offset(size.width, size.height), radius: Radius.circular(1000));
//    path.lineTo(size.width, 0);
//    path.close();
    double radius = 120;

    /* path.moveTo(radius, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius));
//    path.lineTo(0, radius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, radius);

    path.lineTo(size.width-radius, 0);
    path.close();
*/
    path.moveTo(0, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius/2));
//    path.lineTo(0, radius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, radius);
    path.arcToPoint(Offset(size.width, 0), radius: Radius.circular(radius/2));

    path.close();

    return path;
  }

  @override
  bool shouldReclip (VoucherClipper oldClipper) => true;

}

