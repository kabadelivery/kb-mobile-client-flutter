import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/recustomlib/my_qrcode_reader_view.dart';

class QrCodeScannerPage extends StatefulWidget {

  static var routeName = "/QrCodeScannerPage";

  QrCodeScannerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QrCodeScannerPageState createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage> {

   GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrcodeReaderView(key: qrViewKey, onScan: onScan)
    );
  }

  Future onScan(String data) async {
    qrViewKey.currentState.stopScan();
    /* return the data to the other view */
    Navigator.of(context).pop({'data':data});
  }

}
