import 'package:KABA/src/ui/customwidgets/MRaisedButton.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DialogPage extends AlertDialog {
  var onClickAction1, onClickAction2;

  String? message;

  String? pic;

  int? nbAction;

  String? button1Name, button2Name;

  DialogPage({
    Key? key,
    this.message,
    this.pic,
    this.nbAction,
    this.button1Name,
    this.button2Name,
    this.onClickAction1,
    this.onClickAction2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: (Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: KColors.primaryYellowColor, width: 2),
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(pic!)))),
          SizedBox(height: 10),
          Text(message!, textAlign: TextAlign.center),
          SizedBox(height: 10),
          nbAction == 1
              ? MRaisedButton(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child:
                      Text(button1Name!, style: TextStyle(color: Colors.white)),
                  onPressed: onClickAction1,
                  color: KColors.primaryColor)
              : (Row(children: <Widget>[
                  MRaisedButton(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(button1Name!,
                          style: TextStyle(color: Colors.white)),
                      onPressed: onClickAction1,
                      color: KColors.primaryColor),
                  SizedBox(width: 10),
                  MRaisedButton(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(button2Name!,
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: onClickAction2,
                      color: Colors.white)
                ]))
        ])),
      ),
    );
  }
}
