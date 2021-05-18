import 'dart:io';

import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:audioplayers/audioplayers.dart';
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


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null)
        setState(() {
          _playMusicForSuccess();
          controller?.dispose();
          /* wait for 500s and get out */
          Future.delayed(Duration(milliseconds: 300)).then((value){
            Navigator.of(context).pop({"qrcode": scanData});
          });
        });
    });
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
    AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    audioPlayer.setVolume(1.0);
    AudioPlayer.logEnabled = true;
    var audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.play(MusicData.scan_catch);
    if (await Vibration.hasVibrator ()) {
      Vibration.vibrate(duration: 100);
    }
  }



}
