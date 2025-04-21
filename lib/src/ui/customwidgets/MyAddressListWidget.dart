import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class MyAddressListWidget extends StatefulWidget {

  DeliveryAddressModel? address;

  bool? pick;

  var parentContext;

  MyAddressListWidget({this.address, this.pick = false, this.parentContext});

  @override
  _MyAddressListWidgetState createState() {
    return _MyAddressListWidgetState();
  }

}

class _MyAddressListWidgetState extends State<MyAddressListWidget> {


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
          Card(child: InkWell(
            child: Container(padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded (child: Container (child: Text("${widget.address?.name?.toUpperCase()}", style: TextStyle(color: KColors.new_black.withAlpha(180), fontWeight: FontWeight.bold,fontSize: 18)))),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded (
                        child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text("${widget.address?.description}",maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          IconButton(icon: Icon(FontAwesomeIcons.penFancy, color: CommandStateColor.shipping), splashColor: Colors.grey, onPressed: ()=>_editAddress(widget.address!)),
                        ],
                      ),
                    ],
                  ),
                  Row(children: <Widget>[Text("Contact", style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16,color:KColors.new_black)), SizedBox(width: 10),
                    Text("${widget.address?.phone_number}", style: TextStyle(fontSize: 16, color: CommandStateColor.delivered, fontWeight: FontWeight.bold))])
                ],
              ),
            ),
          )
          )
      );
  }

  _editAddress(DeliveryAddressModel address) {
  /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(address: address),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            EditAddressPage(address: address),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }


}