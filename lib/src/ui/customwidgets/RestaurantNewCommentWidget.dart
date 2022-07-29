import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class RestaurantNewCommentWidget extends StatelessWidget {

  CommentModel  comment;

  RestaurantNewCommentWidget({
    Key key,
    this.comment,
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top:10, bottom:10),
        color: Colors.white,
        child:ListTile(
          leading: Container(
            decoration: BoxDecoration(
                color: CommandStateColor.waiting.withAlpha(50),
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(Utils.inflateLink(comment.pic))
                )
            ),
            height:50, width: 50,
          ),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(width: MediaQuery.of(context).size.width*0.85,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: RichText(text: TextSpan(
                          text: comment.name_of_client.trim(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12)
                        , children: [
                          TextSpan(text:"  "+ comment.content.trim(),  style: TextStyle(color:Colors.grey,  fontWeight: FontWeight.normal, fontSize: 12))
                        ])),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                  Row(children: <Widget>[]
                    ..addAll(
                        List<Widget>.generate(comment.stars.toInt(), (int index) {
                          return Icon(FontAwesomeIcons.solidStar, color: KColors.primaryYellowColor, size: 14);
                        })
                      // ..add((comment.stars*10)%10 != 0 ? Icon(Icons.star, color: KColors.primaryYellowColor, size: 16) : Container())
                    )),   Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("${Utils.readTimestamp(context, comment?.created_at)}",   style: TextStyle(color:Colors.grey, fontSize: 12)),
                    ],
                  ),
                ])
              ]
          ),
        ));
  }
}