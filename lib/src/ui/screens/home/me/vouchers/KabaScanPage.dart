import 'package:KABA/src/models/CustomerModel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null)
        setState(() {
          controller?.dispose();
          Navigator.of(context).pop({"qrcode": scanData});
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





}
