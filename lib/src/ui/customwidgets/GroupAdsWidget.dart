import 'dart:ui';

import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';


class GroupAdsWidget extends StatefulWidget {

  GroupAdsModel groupAd;

  GroupAdsWidget({
    Key key,
    this.groupAd,
  }): super(key:key);

  @override
  _GroupAdsWidgetState createState() => _GroupAdsWidgetState();
}

class _GroupAdsWidgetState extends State<GroupAdsWidget> {
  @override
  Widget build(BuildContext context) {
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
                                Expanded( // big add
                                  flex: 2,
                                  child: GestureDetector(onTap: ()=>_jumpToAdsList([widget.groupAd.big_pub, widget.groupAd.small_pub], 0),
                                    child: OptimizedCacheImage(fit:BoxFit.cover,imageUrl: Utils.inflateLink(widget.groupAd.big_pub.pic)),
                                  ),
                                ),
                                Expanded( // small add
                                    flex: 1,
                                    child: GestureDetector(onTap:()=>_jumpToAdsList([widget.groupAd.big_pub, widget.groupAd.small_pub], 1),
                                        child:Container(
                                          child: OptimizedCacheImage(fit:BoxFit.cover, imageUrl: Utils.inflateLink(widget.groupAd.small_pub.pic)),
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
                          /*    SizedBox(height: 3),
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
                                            image: OptimizedCacheImageProvider("https://photosfine.files.wordpress.com/2012/04/white-background-fruit-and-vegetables-18.jpg")
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
                                            image: OptimizedCacheImageProvider("https://www.netsolutions.com/insights/wp-content/uploads/2018/10/Zomato-online-food-delivery-app.jpg")
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
                                            image: OptimizedCacheImageProvider("https://www.thesun.co.uk/wp-content/uploads/2019/10/VP-COMP-KFC-V2.jpg")
                                        )
                                    )
                                ),
                              ),
                            ]),
                          )*/
                        ])
                ),
//                 title
                Positioned(
                    top:15,
                    child:
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight:Radius.circular(7), bottomRight:Radius.circular(7)), color: KColors.primaryColor),
                        child:Text(
                            widget.groupAd.title?.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 14)
                        ))),
              ])
      );
  }

  _jumpToAdsList(List<AdModel> slider, int position) {

   /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsPreviewPage(data: slider, position:position, presenter: AdsViewerPresenter()),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            AdsPreviewPage(data: slider, position:position, presenter: AdsViewerPresenter()),
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