import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
// import 'package:KABA/src/ui/screens/home/me/vouchers/KabaScanPage.old';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
//import 'package:qrscan/qrscan.dart' as scanner;


class MyVouchersPage extends StatefulWidget {

  static var routeName = "/MyVouchersPage";

  VoucherPresenter presenter;

  CustomerModel customer;

  List<VoucherModel> data;

  bool pick;

  List<int> foods;

  int restaurantId;

  MyVouchersPage({Key key, this.presenter, this.pick = false, this.restaurantId = -1, this.foods, this.title}) : super(key: key);

  final String title;

  @override
  _MyVouchersPageState createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> implements VoucherView {

  String barcode = "";

  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  void initState() {
    widget.presenter.voucherView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      // according to if we are picking something, we can just request stuffs differently
      widget.presenter.loadVoucherList(customer: customer, restaurantId: widget.restaurantId, foodsId: widget.foods);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('my_vouchers')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: (){Navigator.pop(context);}),
        actions: <Widget>[
          // IconButton(icon: Icon(FontAwesomeIcons.qrcode, color: KColors.new_black),onPressed: ()=>_jumpToAddNewVoucher_Scan()),
          IconButton(icon: Icon(Icons.add_box, color: Colors.white),onPressed: ()=>_jumpToAddNewVoucher_Code())
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: isLoading ? Center(child:MyLoadingProgressWidget()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildVouchersList())
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                /*     MRaisedButton(child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.add, color: KColors.primaryColor),
                      SizedBox(width: 10),
                      Text("${AppLocalizations.of(context)!.translate('create_new_address')}", style: TextStyle(color: KColors.primaryColor))
                    ],
                  ),
                ), color: KColors.primaryColorTransparentADDTOBASKETBUTTON, onPressed: () => _createAddress()),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)!.translate('system_error')}",onClickAction: (){  widget.presenter.loadVoucherList(customer: widget.customer, restaurantId: widget.restaurantId, foodsId: widget.foods); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)!.translate('network_error')}",onClickAction: (){
      widget.presenter.loadVoucherList(customer: widget.customer, restaurantId: widget.restaurantId, foodsId: widget.foods);
    });
  }

  /*
  Future _jumpToAddNewVoucher_Scan() async {


    if (!(await Permission.camera.request().isGranted)) {
      return;
    }

    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            KabaScanPage(customer: widget.customer),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));

    if (results.containsKey("qrcode")) {
      String qrCode = results["qrcode"];
      /* continue transaction with this*/
      _jumpToAddNewVoucher_Code(qrCode: qrCode?.toUpperCase());
    } else
      mDialog("${AppLocalizations.of(context)!.translate('qr_code_wrong')}");


    /* check if this code could be a code */
//    if (_checkPromoCode(promoCode)) {
//      _jumpToAddNewVoucher_Code(qrCode: promoCode);
//    } else {
//      mDialog("${AppLocalizations.of(context)!.translate('qr_code_wrong')}");
//    }
  }
*/

  bool _checkPromoCode(String promoCode) {
    if (promoCode?.length < 3 || promoCode?.length>15 || promoCode.contains(":") || promoCode.contains(".")) {
      return false;
    }
    return true;
  }


  Future _jumpToAddNewVoucher_Code({String qrCode = ""}) async {
    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            AddVouchersPage(presenter: AddVoucherPresenter(), customer: widget.customer, qrCode: qrCode),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
    // when you come back,
    widget.presenter.loadVoucherList(customer: widget.customer, restaurantId: widget.restaurantId, foodsId: widget.foods);
  }


  /// Deal with QRCode data
  ///
  ///  launch a stream request to redirect to the related voucher ; we need to see if
  ///  - have we dont have it, subscribe
  ///  - if can't just, tell the customer that you cant subscribe to this because ....
  ///  - if already subscribe, just show the details of the voucher to the client
  kk(Map results) {
    Toast.show(results['data'], context, duration: Toast.LENGTH_LONG);
  }

  @override
  void inflateVouchers(List<VoucherModel> vouchers) {
    setState(() {
      widget.data = vouchers;
    });
  }

  @override
  void networkError() {
    setState(() {
      hasNetworkError = true;
    });
  }


  @override
  void systemError() {
    setState(() {
      hasSystemError = true;
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

  _buildVouchersList() {

    if (widget.data?.length == null || widget.data?.length == 0){
      // no size
      return Center(
          child:GestureDetector(
            onTap: () => _jumpToAddNewVoucher_Code(),
            child:  Shimmer(
              duration: Duration(seconds: 3), //Default value
              color: Colors.white, //Default value
              enabled: true, //Default value
              direction: ShimmerDirection.fromLTRB(),
              child: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: Icon(Icons.add, color: Colors.grey)),
                      SizedBox(width: 10),
                      IconButton(icon: Icon(Icons.card_giftcard, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("${AppLocalizations.of(context)!.translate('sorry_no_coupon')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
          ));
    }

    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
          ]..addAll(
              List<Widget>.generate(widget.data?.length+1, (int index) {
                if (index < widget.data?.length)
                  return MyVoucherMiniWidget(voucher: widget.data[index], pick: widget.pick);
                else
                  return Container(height: 100);
              })
          )
      ),
    );
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        svgIcons,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text("${AppLocalizations.of(context)!.translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context)!.translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }



}

