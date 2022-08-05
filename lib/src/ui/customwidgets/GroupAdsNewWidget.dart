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

class GroupAdsNewWidget extends StatefulWidget {
  GroupAdsModel groupAd;

  GroupAdsNewWidget({
    Key key,
    this.groupAd,
  }) : super(key: key);

  @override
  _GroupAdsNewWidgetState createState() => _GroupAdsNewWidgetState();
}

class _GroupAdsNewWidgetState extends State<GroupAdsNewWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 20),
      child: (Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.groupAd.title,
                  style: TextStyle(color: KColors.primaryColor,fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
                child: Column(children: <Widget>[
                  GestureDetector(
                    onTap: () => _jumpToAdsList(
                        [widget.groupAd.big_pub, widget.groupAd.small_pub], 0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    Utils.inflateLink(
                                        widget.groupAd.big_pub.pic)))),
                        width: MediaQuery.of(context).size.width,
                        height: 9 * MediaQuery.of(context).size.width / 16,
                      ),
                    ),
                  ),
                ])),
//                 title
          Container(width: MediaQuery.of(context).size.width, padding: EdgeInsets.all(10),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      border: new Border.all(
                          color: KColors.primaryYellowColor, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Utils.inflateLink(widget?.groupAd?.small_pub?.pic))))),
              SizedBox(width: 10,),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("${widget.groupAd?.big_pub?.name}", style: TextStyle(color: KColors.new_black, fontSize: 14)),
                  SizedBox(height: 5),
                  Text("${widget.groupAd?.big_pub?.description}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              )
            ]
          ))
          ])),
    );
  }

  _jumpToAdsList(List<AdModel> slider, int position) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsPreviewPage(data: slider, position:position, presenter: AdsViewerPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AdsPreviewPage(
            data: slider, position: position, presenter: AdsViewerPresenter()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }
}
