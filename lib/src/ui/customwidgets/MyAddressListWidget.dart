import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          Card(child:ListTile(
            title: Padding(padding: EdgeInsets.only(top: 10), child: Text("${address?.name?.toUpperCase()}", style: TextStyle(color: Colors.black.withAlpha(180), fontWeight: FontWeight.bold,fontSize: 18))),
            subtitle: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text("${address?.description}",maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ],
                ),
                Row(children: <Widget>[Text("Contact", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color:Colors.black)), SizedBox(width: 10),
                  Text("${address?.phone_number}", style: TextStyle(fontSize: 16, color: Colors.lightBlue, fontWeight: FontWeight.bold))])
              ],
            ),
            trailing: IconButton(icon: Icon(Icons.edit, color: Colors.blue), splashColor: Colors.red, onPressed: ()=>_editAddress(address)),
          ))
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