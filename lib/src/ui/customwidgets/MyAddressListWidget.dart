import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class MyAddressListWidget extends StatefulWidget {

  DeliveryAddressModel address;

  MyAddressListWidget({this.address});

  @override
  _MyAddressListWidgetState createState() {
    // TODO: implement createState
    return _MyAddressListWidgetState(address);
  }

}

class _MyAddressListWidgetState extends State<MyAddressListWidget> {

  DeliveryAddressModel address;

  _MyAddressListWidgetState(this.address);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          Card(child: Container(padding: EdgeInsets.all(10),
            child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded (child: Container (child: Text("${address?.name?.toUpperCase()}", style: TextStyle(color: Colors.black.withAlpha(180), fontWeight: FontWeight.bold,fontSize: 18)))),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded (
                        child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text("${address?.description}",maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      ),
                      IconButton(icon: Icon(FontAwesomeIcons.penFancy, color: CommandStateColor.shipping), splashColor: Colors.grey, onPressed: ()=>_editAddress(address)),
                    ],
                  ),
                  Row(children: <Widget>[Text("Contact", style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16,color:Colors.black)), SizedBox(width: 10),
                    Text("${address?.phone_number}", style: TextStyle(fontSize: 16, color: CommandStateColor.delivered, fontWeight: FontWeight.bold))])
                ],
              ),
          ),
          )
      );
  }

  _editAddress(DeliveryAddressModel address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(address: address),
      ),
    );
  }



}