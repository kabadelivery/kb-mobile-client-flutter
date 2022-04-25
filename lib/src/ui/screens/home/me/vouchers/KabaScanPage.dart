import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

import 'AddVouchersPage.dart';


class KabaScanPage extends StatefulWidget {

  static var routeName = "/KabaScanPage";

//  AddVoucherPresenter presenter;

  CustomerModel customer;

  KabaScanPage({Key key, this.customer/*, this.presenter*/}) : super(key: key);

  @override
  _KabaScanPageState createState() => _KabaScanPageState();
}

class _KabaScanPageState extends State<KabaScanPage>  {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  var sdkInt = -1;

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((AndroidDeviceInfo androidInfo) {
      setState(() {
        sdkInt = androidInfo.version.sdkInt;
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isIOS ?
      Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
              ),
              /*  Expanded(
                flex: 1,
                child: Center(
                  child: Text('Scan result: $qrText'),
                ),
              )*/
            ],
          ),
          Positioned(left: 10, top:35, child: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(FontAwesomeIcons.timesCircle, size: 30, color: Colors.white))),
        ],
      )
          : (sdkInt == -1 ? Center(child: CircularProgressIndicator()) :
      (sdkInt >= 24 ?
          Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
              ),
              /*  Expanded(
                flex: 1,
                child: Center(
                  child: Text('Scan result: $qrText'),
                ),
              )*/
            ],
          ),
          Positioned(left: 10, top:35, child: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(FontAwesomeIcons.timesCircle, size: 30, color: Colors.white))),
        ],
      ) :
        _buildSorryVersionNotAllowed()
    )
    ));
  }

   _buildSorryVersionNotAllowed () {
     return Center(
       child: (
           Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                 /* text / image
                    * button */
                 SizedBox(width: 40, height: 40,
                     child: IconButton(icon: Icon(FontAwesomeIcons.qrcode, color: KColors.primaryColor))),
                 SizedBox(height: 5),
                 Container(margin: EdgeInsets.only(left:10, right: 10), child: Text("${AppLocalizations.of(context).translate('sorry_version_not_allowed')}", textAlign: TextAlign.center)),
                 SizedBox(height:10),
                 MaterialButton(
                     padding: EdgeInsets.only(top: 10,bottom: 10, right:10,left:10), child:Text("${AppLocalizations.of(context).translate('exit')}",
                     style: TextStyle(color: Colors.white)),
                     onPressed: () {
                       /* call me */
                       Navigator.of(context).pop();
                       _jumpToAddVoucherPage();
                     }, color: KColors.primaryColor)
               ])
       ),
     );
  }

  void _jumpToAddVoucherPage() {
    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            AddVouchersPage(presenter: AddVoucherPresenter(), customer: widget.customer),
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

  Barcode result;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {

      result = scanData;
      if (result != null)
        setState(() {
          _playMusicForSuccess();
          controller?.dispose();
          /* wait for 500s and get out */
          Future.delayed(Duration(milliseconds: 300)).then((value){

            /* check if the data maps with a specific URI, if yes go on...
                otherwise check if goes to the */
            Navigator.of(context).pop({"qrcode": result.code});
          });
        });
    });
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  String _handleLinksImmediately(String data) {
    /* streams */

    // if you are logged in, we can just move to the activity.
    Uri mUri = Uri.parse(data);

    List<String> pathSegments = mUri.pathSegments.toList();
    var arg = null;

    if ("${mUri.host}" != ServerConfig.APP_SERVER_HOST || pathSegments.length == 0
        || mUri.scheme != "https") {
      return data;
    }

    if (pathSegments.length > 0) {
      switch (pathSegments[0]) {
        case "voucher":
          if (pathSegments.length > 1) {
            xrint("voucher id homepage -> ${pathSegments[1]}");
            // widget.destination = SplashPage.VOUCHER;
            /* convert from hexadecimal to decimal */
            arg = "${pathSegments[1]}";
            _jumpToPage(context, AddVouchersPage(
                presenter: AddVoucherPresenter(),
                qrCode: "${arg}".toUpperCase(),
                customer: widget.customer));
          }
          break;
        case "vouchers":
          xrint("vouchers page");
          /* convert from hexadecimal to decimal */
          _jumpToPage(context, MyVouchersPage(presenter: VoucherPresenter()));
          break;
        case "addresses":
          xrint("addresses page");
          /* convert from hexadecimal to decimal */
          _jumpToPage(context, MyAddressesPage(presenter: AddressPresenter()));
          break;
        case "transactions":
          _jumpToPage(
              context,
              TransactionHistoryPage(presenter: TransactionPresenter()));
          break;
        case "restaurants":
          StateContainer.of(context).updateTabPosition(tabPosition: 1);
          Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(
              settings: RouteSettings(name: HomePage.routeName),
              builder: (BuildContext context) => HomePage()), (r) => false);
          break;
        case "restaurant":
          if (pathSegments.length > 1) {
            xrint("restaurant id -> ${pathSegments[1]}");
            /* convert from hexadecimal to decimal */
            arg = int.parse("${pathSegments[1]}");
            _jumpToPage(context, RestaurantDetailsPage(
                restaurant: RestaurantModel(id: arg),
                presenter: RestaurantDetailsPresenter()));
          }
          break;
        case "order":
          if (pathSegments.length > 1) {
            xrint("order id -> ${pathSegments[1]}");
            arg = int.parse("${pathSegments[1]}");
            _jumpToPage(context, OrderDetailsPage(
                orderId: arg, presenter: OrderDetailsPresenter()));
          }
          break;
        case "food":
          if (pathSegments.length > 1) {
            xrint("food id -> ${pathSegments[1]}");
            arg = int.parse("${pathSegments[1]}");
            _jumpToPage(context, RestaurantMenuPage(
                foodId: arg, presenter: MenuPresenter()));
          }
          break;
        case "menu":
          if (pathSegments.length > 1) {
            xrint("menu id -> ${pathSegments[1]}");
            arg = int.parse("${pathSegments[1]}");
            _jumpToPage(context, RestaurantMenuPage(
                menuId: arg, presenter: MenuPresenter()));
          }
          break;
        case "review-order":
          if (pathSegments.length > 1) {
            xrint("review-order id -> ${pathSegments[1]}");
            arg = int.parse("${pathSegments[1]}");
            _jumpToPage(context, OrderDetailsPage(
                orderId: arg, presenter: OrderDetailsPresenter()));
          }
          break;
      }
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

    /*return Scaffold(
      body: QRView(
        key: qrKey,
        overlay: QrScannerOverlayShape(
            borderRadius: 16,
            borderColor: Colors.white,
            borderLength: 120,
            borderWidth: 10,
            cutOutSize: 250),
        onQRViewCreated: _onQRViewCreate,
        data: "KABA-${widget.customer?.phone_number}",// Showing qr code data
      )
    );*/


/*
  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null)
      setState(() {
//        print("QRCode: $scanData");
        controller?.dispose();
        Navigator.of(context).pop({"qrcode": scanData});
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }*/

  Future<void> _playMusicForSuccess() async {
    // play music
    // AudioPlayer audioPlayer = AudioPlayer();
    // audioPlayer.play(MusicData.scan_catch, isLocal: true);
    final player = AudioPlayer();
    player.play(MusicData.scan_catch);
    if (await Vibration.hasVibrator ()) {
      Vibration.vibrate(duration: 100);
    }
  }



}
