import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/QrCodeScanner.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:toast/toast.dart';


class MyVouchersPage extends StatefulWidget {

  static var routeName = "/MyVouchersPage";

  VoucherPresenter presenter;

  CustomerModel customer;

  List<VoucherModel> data;

  bool pick;

  List<int> foods;

  int restaurantId;

  MyVouchersPage({Key key, this.presenter, this.pick = false, this.restaurantId, this.foods, this.title}) : super(key: key);

  final String title;

  @override
  _MyVouchersPageState createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> implements VoucherView {

  String barcode = "";

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  void initState() {
    widget.presenter.voucherView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      // according to if we are picking something, we can just request stuffs differently
      widget.presenter.loadVoucherList(customer);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("${AppLocalizations.of(context).translate('my_vouchers')}", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildVouchersList())
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                /*     RaisedButton(child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.add, color: KColors.primaryColor),
                      SizedBox(width: 10),
                      Text("${AppLocalizations.of(context).translate('create_new_address')}", style: TextStyle(color: KColors.primaryColor))
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
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.loadVoucherList(widget.customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){
      widget.presenter.loadVoucherList(widget.customer);
    });
  }

  Future _jumpToAddNewVoucher() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrCodeScannerPage(),
      ),
    ).then((results)=>kk(results));
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
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.card_giftcard, color: Colors.grey)),
              SizedBox(height: 10),
              Text("${AppLocalizations.of(context).translate('sorry_no_coupon')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ));
    }

    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
          ]..addAll(
              List<Widget>.generate(widget.data?.length+1, (int index) {
                if (index < widget.data?.length)
                  return MyVoucherMiniWidget(voucher: widget.data[index]);
                else
                  return Container(height: 100);
              })
          )
      ),
    );
  }

}

