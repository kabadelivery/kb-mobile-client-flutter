import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';

class MyOrderWidget extends StatefulWidget {

  String text;

  MyOrderWidget({this.text});

  @override
  _MyOrderWidgetState createState() {
    // TODO: implement createState
    return _MyOrderWidgetState();
  }

}

class _MyOrderWidgetState extends State<MyOrderWidget> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            /* decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),   boxShadow: [
                new BoxShadow(
                  color: Colors.grey..withAlpha(50),
                  offset: new Offset(0.0, 2.0),
                )
              ]),*/
              child:
              Column(children: <Widget>[
                ListTile(
                    contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                    leading: Container(
                      height:50, width: 50,
                      child:CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png"),
                    ),
                    trailing: IconButton(icon: Icon(Icons.menu, color: KColors.primaryColor,), onPressed: (){}),
                    title:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("CHEZ ARMANDINE", textAlign: TextAlign.left, style: TextStyle(color:KColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w500)),
                        SizedBox(height:10),
                        Text("Qtier Agoe Plateaux; Agence-annexe - We are not very far from carefour assigomé! Turn right and we are there", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    )
                ),
                Container(
                    padding: EdgeInsets.all(5),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: Colors.blueAccent.shade700),
                            child:Text(
                                "Closed",
                                style: TextStyle(color: Colors.white, fontSize: 12)
                            )),
                        Text("2.15km", style: TextStyle(color: Colors.grey.shade700, fontSize: 12))
                      ],
                    ))
              ])
          ))
      );
  }



}