import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'my_qrcode_reader_view.dart';

class QrCodeScannerPage extends StatefulWidget {

  static var routeName = "/QrCodeScannerPage";

  QrCodeScannerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QrCodeScannerPageState createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage> {

   GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();

  var qrReaderView =  QrReaderView(
    width: 320,
    height: 350,
    callback: (container) {},
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child:  QrcodeReaderView(key: qrViewKey, onScan: onScan) // 嵌入视图
          ),
        ],
      ),
    );
  }

  Future onScan(String data) async {
    qrViewKey.currentState.stopScan();
    /* return the data to the other view */
    Navigator.of(context).pop({'data':data});
  }

}
