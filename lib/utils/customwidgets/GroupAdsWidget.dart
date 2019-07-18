import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/_data/model/_AdModel.dart';


class GroupAdsWidget extends StatefulWidget {

  String title;
  var bigAd;
  var lilAd;

  GroupAdsWidget({this.title="CADILLAC", this.bigAd, this.lilAd});

  @override
  _GroupAdsWidgetState createState() {
    // TODO: implement createState
    return _GroupAdsWidgetState();
  }

}

class _GroupAdsWidgetState extends State<GroupAdsWidget> {


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
          Stack(
              children: <Widget>[
                Container(
                  color: Colors.grey.shade300,
                    padding: EdgeInsets.only(top:30),
                    child: Column(
                        children:<Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width/3,
                            child: Row(
                              children: <Widget>[
                                /* 2 views */
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      child: CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png"),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                        child:Container(
                                          child: CachedNetworkImage(fit:BoxFit.cover, imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Purple124/v4/bc/8b/97/bc8b9746-1d09-8aa1-38bf-359b118eed1e/AppIcon-0-1x_U007emarketing-0-0-GLES2_U002c0-512MB-sRGB-0-0-0-85-220-0-0-0-6.png/246x0w.jpg"),
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                            color:Colors.white,
                              padding: EdgeInsets.only(right:5, left:5, bottom:10, top:10),
                              margin: EdgeInsets.only(bottom: 20),
                              child: Row(
                                  children: <Widget>[
                                    Expanded(flex:2,
                                        child: Text("BONNE ST-VALENTIN")),
                                    Expanded(flex:1,
                                        child: Text("LE PATIO")),
                                  ]
                              ))
                        ])
                ),
                /* title */
                Positioned(
                    top:15,
                    child:
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: KColors.primaryColor),
                        child:Text(
                            widget.title,
                            style: TextStyle(color: Colors.white, fontSize: 14)
                        ))),
              ])
      );
  }



}