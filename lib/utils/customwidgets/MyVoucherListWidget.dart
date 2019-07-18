import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';


class MyVoucherListWidget extends StatefulWidget {

  MyVoucherListWidget();

  @override
  _MyVoucherListWidgetState createState() {
    // TODO: implement createState
    return _MyVoucherListWidgetState();
  }

}

class _MyVoucherListWidgetState extends State<MyVoucherListWidget> {


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
          Card(
            color: Colors.orange.withAlpha(120),
              child:Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
              child:Column(
            children: <Widget>[
              /* top level */
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children: <Widget>[
                Text("WINGS'S SHAKE BAGUIDA"),
                Row(children: <Widget>[/* icon */IconButton(icon: Icon(Icons.person, color: Colors.white), onPressed: () {},), /*text */Text("2/4")])
              ]),
              /* middle level*/
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children: <Widget>[
                Text("PAQUES2019", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("-55%",style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black.withAlpha(150))),
              ]),
              /* bottom level */
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,  children: <Widget>[
              Row(children: <Widget>[/* icon */IconButton(icon: Icon(Icons.watch_later, color: Colors.black), onPressed: () {},), /*text */Text("2019/04/05")]),
                IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {},)
              ]),
            ]
          )))
      );
  }

  _editAddressAt(int position) {


  }



}