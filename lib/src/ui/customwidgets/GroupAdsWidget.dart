import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class GroupAdsWidget extends StatelessWidget {

  GroupAdsModel groupAd;

  GroupAdsWidget({
    Key key,
    this.groupAd,
  }): super(key:key);

  /*@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          Column(
              children: <Widget>[
                Container(
                    color: Colors.grey.shade100,
                    margin: EdgeInsets.only(left:20, right:20),
                    child: Column(
                        children:<Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width/2,
                            child: Row(
                              children: <Widget>[
                                *//* 2 views *//*
                                Expanded(
                                    flex: 1,
                                    child: Container(width: MediaQuery.of(context).size.width/2, height: MediaQuery.of(context).size.width/2,
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: KColors.primaryColor),
                                        child:Container(
                                          child: FittedBox(fit: BoxFit.fitWidth,
                                            child: Text(
                                                groupAd.title.trim().toUpperCase(),
//                                            "OP\ER\nA",
                                                style: TextStyle(color: Colors.white)
                                            ),
                                          ),
                                        ))),
                                Expanded(
                                    flex: 1,
                                    child: Container(width: MediaQuery.of(context).size.width/2, height: MediaQuery.of(context).size.width*2,
                                      padding: EdgeInsets.all(5),
                                      margin: EdgeInsets.only(right: 5, top:5, bottom:5),
                                      decoration: BoxDecoration(
                                          border: new Border.all(
                                              color: Colors.transparent, width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(7)),
                                          shape: BoxShape.rectangle,
                                          image: new DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider( Utils.inflateLink(groupAd.small_pub.pic))
                                          )
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: Colors.transparent, width: 2),
                                borderRadius: BorderRadius.all(Radius.circular(7)),
                                shape: BoxShape.rectangle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider( Utils.inflateLink(groupAd.big_pub.pic))
                                )
                            ),
//                              color:Colors.transparent,
                            margin: EdgeInsets.only(right:5, left:5, bottom:10),
                            height: MediaQuery.of(context).size.width/3,
                          ),
                        ])
                ),
              ])
      );
  }*/


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          Stack(
              children: <Widget>[
                Container(  margin: EdgeInsets.only(bottom: 20),
                    color: Colors.grey.shade300.withAlpha(50),
                    padding: EdgeInsets.only(top:30),
                    child: Column(
                        children:<Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width/3,
                            child: Row(
                              children: <Widget>[
//                                 2 views
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      child: CachedNetworkImage(fit:BoxFit.cover,imageUrl: Utils.inflateLink(groupAd.big_pub.pic)),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                        child:Container(
                                          child: CachedNetworkImage(fit:BoxFit.cover, imageUrl: Utils.inflateLink(groupAd.small_pub.pic)),
                                        ))),
                              ],
                            ),
                          ),
                          /* Container(
                            color:Colors.white,
                              padding: EdgeInsets.only(right:5, left:5, bottom:10, top:10),
                              child: Row(
                                  children: <Widget>[
                                    Expanded(flex:2,
                                        child: Text(groupAd.big_pub.name)),
                                    Expanded(flex:1,
                                        child: Text(groupAd.small_pub.name)),
                                  ]
                              )),*/
                          /* space for those white backgroud images */
                          SizedBox(height: 3),
                          Container(
                            color: Colors.grey.shade300.withAlpha(50),
                            child: Row(mainAxisSize: MainAxisSize.max,children: <Widget>[
                              Expanded(
                                flex: 1,
                                child:Container(
                                    height: MediaQuery.of(context).size.width/3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        image: new DecorationImage(
                                            fit: BoxFit.contain,
                                            image: CachedNetworkImageProvider("https://lh3.googleusercontent.com/proxy/tovoF2Sr6urlCZekpPEZEt3Ziihsy55UvqhBcpmsP9NQL4cwwFAngAXs_78cLwsavCoBQgTBrMFWsZntrukiz5QDwwfVXfYv")
                                        )
                                    )
                                ),
                              ),
                              SizedBox(width: 1),
                              Expanded(
                                flex: 1,
                                child:Container(
                                    height: MediaQuery.of(context).size.width/3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        image: new DecorationImage(
                                            fit: BoxFit.contain,
                                            image: CachedNetworkImageProvider("https://www.netsolutions.com/insights/wp-content/uploads/2018/10/Zomato-online-food-delivery-app.jpg")
                                        )
                                    )
                                ),
                              ),
                              SizedBox(width: 1,),
                              Expanded(
                                flex: 1,
                                child:Container(
                                    height: MediaQuery.of(context).size.width/3,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        image: new DecorationImage(
                                            fit: BoxFit.contain,
                                            image: CachedNetworkImageProvider("https://www.thesun.co.uk/wp-content/uploads/2019/10/VP-COMP-KFC-V2.jpg")
                                        )
                                    )
                                ),
                              ),
                            ]),
                          )
                        ])
                ),
//                 title
                Positioned(
                    top:15,
                    child:
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: KColors.primaryColor),
                        child:Text(
                            groupAd.title?.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 14)
                        ))),
              ])
      );
  }

}