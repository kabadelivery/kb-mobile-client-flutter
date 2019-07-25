import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyAddressListWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyVoucherListWidget.dart';


class MyVouchersPage extends StatefulWidget {

  static var routeName = "/MyVouchersPage";

  MyVouchersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyVouchersPageState createState() => _MyVouchersPageState();
}

class _MyVouchersPageState extends State<MyVouchersPage> {

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
      body: SingleChildScrollView(
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
      ),
    );
  }

  void _jumpToAddNewVoucher() {


  }

}
