import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyAddressListWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyVoucherListWidget.dart';


class AddVouchersPage extends StatefulWidget {

  static var routeName = "/AddVouchersPage";

  AddVouchersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddVouchersPageState createState() => _AddVouchersPageState();
}

class _AddVouchersPageState extends State<AddVouchersPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("NEW VOUCHER", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              Container(padding: EdgeInsets.all(10), child: Text("Please insert the CODE of your voucher to subscribe and get it!", style: TextStyle(fontSize: 14, color: Colors.black.withAlpha(150)), textAlign: TextAlign.center)),
              SizedBox(height: 40),
              /* input text */
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                SizedBox(width:200, child: TextField(textCapitalization: TextCapitalization.characters,
                    decoration: new InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: KColors.primaryColor)),
                        labelText: 'CODE PROMO',
                        prefixIcon: const Icon(
                          Icons.repeat,
                          color: KColors.primaryYellowColor,
                        )))),
                /* button */
//                SizedBox(width: 10),
                FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {},
                    child: Icon(Icons.check_circle, color: KColors.primaryColor)),
              ])
            ]
        ),
      ),
    );
  }

  void _jumpToAddNewVoucher() {

  }

}
