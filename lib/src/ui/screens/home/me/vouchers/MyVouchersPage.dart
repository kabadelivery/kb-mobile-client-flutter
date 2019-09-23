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

    Map results = await Navigator.of(context).pushNamed(QrCodeScannerPage.routeName);

    if (results != null && results.containsKey('data')) {
      setState(() {
        String _data = results['data'];
        print(_data);
      });
    }


  }

}

