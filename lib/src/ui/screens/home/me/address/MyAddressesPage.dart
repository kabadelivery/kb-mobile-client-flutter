import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyAddressListWidget.dart';


class MyAddressesPage extends StatefulWidget {

  static var routeName = "/MyAddressesPage";

  MyAddressesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAddressesPageState createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {

  bool _canReceiveSharedAddress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("MY ADDRESSES", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              SwitchListTile(title: const Text("Bunch of interesting test that im not going to talk too much about.", style: TextStyle(fontSize: 14,color: Colors.grey), textAlign: TextAlign.center), onChanged: (bool value) {setState(() {_canReceiveSharedAddress=(!_canReceiveSharedAddress);});}, value: _canReceiveSharedAddress)
            ]..addAll(
                List<Widget>.generate(12, (int index) {
                  return MyAddressListWidget();
                })
            )
        ),
      ),
    );
  }
}
