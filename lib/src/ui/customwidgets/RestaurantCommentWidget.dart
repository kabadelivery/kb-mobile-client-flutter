import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class RestaurantCommentWidget extends StatelessWidget {

  CommentModel  comment;

  RestaurantCommentWidget({
    Key key,
    this.comment,
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
            height:40, width: 40,
          ),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(comment.name_of_client.trim(), textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("${Utils.readTimestamp(comment?.created_at)}", textAlign: TextAlign.left, style: TextStyle(color:Colors.black.withAlpha(150), fontSize: 12)),
                  ],
                ),
                SizedBox(height: 5),
                Row(children: <Widget>[]
                  ..addAll(
                      List<Widget>.generate(comment.stars.toInt(), (int index) {
                        return Icon(Icons.star, color: KColors.primaryYellowColor, size: 16);
                      })
                  )),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Flexible(child: Text(comment.content.trim(), textAlign: TextAlign.left, style: TextStyle(color:Colors.black.withAlpha(150), fontSize: 15))),
                  ],
                )
              ]
          ),
        ));
  }
}