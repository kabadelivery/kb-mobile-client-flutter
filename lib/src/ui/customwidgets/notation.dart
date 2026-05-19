import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/ShopProductModel.dart';

Widget Notation({required String text,int? count, ShopProductModel? food}) {

  double note = double.parse(text)<1?0.0:double.parse(text);

  return food==null?Container(
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.yellow.withOpacity(.1)),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star, color: KColors.primaryYellowColor, size: 14) ,
        Text('${note.toStringAsFixed(1)}',style: TextStyle(color: Colors.grey,fontSize: 14,),),
      ],
    ),
  ):Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('${note.toStringAsFixed(1)}',style: TextStyle(color: KColors.primaryColor,fontSize: 14,fontWeight: FontWeight.bold),),

      Icon(Icons.star, color: KColors.primaryYellowColor, size: 18) ,
    ],
  );
}

Future<Map?> showReviewDialog(BuildContext context,Widget dialog) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
              color: Colors.white,
              height: 500,
              width: 400,
              child: dialog
          ),
        ),
      );
    },
  );
}