import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyVoucherListWidget.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/vouchers/QrCodeScanner.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:toast/toast.dart';


class MyVouchersPage extends StatefulWidget {

  static var routeName = "/MyVouchersPage";

  MyVouchersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyVouchersPageState createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> {

  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {_jumpToAddNewVoucher();},
          child: Icon(Icons.add, color: KColors.primaryColor)),
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
        backgroundColor: Colors.white,
        title: Text("MY VOUCHERS", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: StreamBuilder<List<MyVouchersPage>>(
          stream: null,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                  ]..addAll(
                      List<Widget>.generate(12, (int index) {
                        return MyVoucherListWidget();
                      })
                  )..add(
                      SizedBox(height: 100)
                  )
              ),
            );
          }
      ),
    );
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

}

