import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


class Group2AdsWidget extends StatefulWidget {

  GroupAdsModel groupAd;

  Group2AdsWidget({
    Key key,
    this.groupAd,
  }): super(key:key);

  @override
  _Group2AdsWidgetState createState() => _Group2AdsWidgetState();
}

class _Group2AdsWidgetState extends State<Group2AdsWidget> {

var miniTitles = ["Faites-vous livrer", "Commandez une chambre", "Mangez saint!"];
var miniImages = [
  "https://image.freepik.com/free-vector/fast-food-icons-set-cartoon-style-isolated-white-background_71374-539.jpg",
  "https://www.zzzone.co.uk/wp-content/uploads/2016/11/Food-Photography-on-a-white-background.jpg",
];

  @override
  Widget build(BuildContext context) {
    return
      (
          Stack(
              children: <Widget>[
                Container(
//                    margin: EdgeInsets.only(bottom: 20),
                    color: Colors.grey.shade100,
                    padding: EdgeInsets.only(top:20, bottom: 20),
                    child: Column(
                        children:<Widget>[
//                          GestureDetector(onTap: ()=>_jumpToAdsList([widget.groupAd.big_pub, widget.groupAd.small_pub], 0), child:
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: OptimizedCacheImageProvider(
//                                        Utils.inflateLink(widget.groupAd.big_pub.pic)
                                        Random().nextInt(3) == 1 ?  "https://vegplatter.in/files/public/inline-images/vegplatter%20banner.png"
                                            : "https://www.brainvire.com/wp-content/uploads/2019/07/BV-PR-Ripsey.jpg"
                                    )
                                ),
                                borderRadius: BorderRadius.only(topRight:Radius.circular(8), topLeft: Radius.circular(8))),
                            margin: EdgeInsets.only(left:10,right: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 5*(MediaQuery.of(context).size.width - 20)/16,
//                            child:  OptimizedCacheImage(fit:BoxFit.cover ,imageUrl: Utils.inflateLink(widget.groupAd.big_pub.pic)),
                          ),
                          /* child: Row(
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
                            ),*/
//                          ),
                          Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(left:10,right:10),
                              padding: EdgeInsets.all(10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    /*   Container(width:MediaQuery.of(context).size.width/4, height:MediaQuery.of(context).size.width/4, color: Colors.red),
                                    Container(width:MediaQuery.of(context).size.width/4, height:MediaQuery.of(context).size.width/4, color: Colors.blue),
                                    Container(width:MediaQuery.of(context).size.width/4, height:MediaQuery.of(context).size.width/4, color: Colors.green),
                                 */
                                  ] ..addAll(
                                      List<Widget>.generate(/*widget.groupAd.level_one.length*/ 3, (int index) {
                                        return Container(width:MediaQuery.of(context).size.width/4, height:3*MediaQuery.of(context).size.width/8, color: Colors.transparent,
                                            child: Column(
                                              children: <Widget>[
                                                OptimizedCacheImage(fit:BoxFit.cover, imageUrl: Utils.inflateLink(
//                                                widget.groupAd.level_one[index].pic)
                                                    "/web/downloads/test/bouffe${index+1}.jpg"
                                                )),
                                                SizedBox(height: 5),
                                                Text(miniTitles[index], textAlign: TextAlign.center,
                                                    style: KStyles.hintTextStyle_gray_11)
                                              ],
                                            )
                                        );
                                      })
                                  )
                              ))
                        ])
                ),
              ])
      );
  }

  _jumpToAdsList(List<AdModel> slider, int position) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsPreviewPage(data: slider, position:position, presenter: AdsViewerPresenter()),
      ),
    );
  }
}